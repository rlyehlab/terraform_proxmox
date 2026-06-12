#!/usr/bin/env bash
# Create a Proxmox Ubuntu cloud-init template from an official cloud image.
# Based on: https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/
#
# Run on the Proxmox node as root:
#   cd create_template/ubuntu
#   cp config.env.example config.env   # edit if needed
#   ./create-template.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.env}"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Missing ${CONFIG_FILE}. Copy config.env.example to config.env and edit it." >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"

required_vars=(
  VMID VM_NAME IMAGE_URL IMAGE_FILE BRIDGE MEMORY CORES
  DISK_STORAGE CLOUDINIT_STORAGE TEMPLATE_DISK_SIZE EXTRA_PACKAGES RUN_VIRT_SYSPREP
)
for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Set ${var} in ${CONFIG_FILE}" >&2
    exit 1
  fi
done

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root on the Proxmox node." >&2
  exit 1
fi

WORKDIR="${WORKDIR:-/var/lib/vz/template/ubuntu-build}"
MIN_IMAGE_BYTES="${MIN_IMAGE_BYTES:-500000000}"
mkdir -p "${WORKDIR}"

# Absolute path to the cloud image (set by prepare_image)
IMAGE_PATH=""

log() {
  printf '==> %s\n' "$*" >&2
}

warn() {
  printf '!!> %s\n' "$*" >&2
}

vmid_in_use() {
  qm status "$1" &>/dev/null
}

resolve_vmid() {
  local id="${VMID}"

  if ! vmid_in_use "${id}"; then
    printf '%s' "${id}"
    return
  fi

  warn "VM/template ${id} already exists; keeping it and creating a new template"
  id=$((VMID + 1))
  while vmid_in_use "${id}"; do
    id=$((id + 1))
  done
  printf '%s' "${id}"
}

image_byte_size() {
  stat -c '%s' "$1"
}

image_is_valid() {
  local path="$1"
  [[ -f "${path}" ]] || return 1
  [[ "$(image_byte_size "${path}")" -ge "${MIN_IMAGE_BYTES}" ]] || return 1
  qemu-img info "${path}" >/dev/null 2>&1
}

validate_image() {
  if [[ ! -f "${IMAGE_PATH}" ]]; then
    echo "Image not found: ${IMAGE_PATH}" >&2
    exit 1
  fi

  local size
  size="$(image_byte_size "${IMAGE_PATH}")"
  if [[ "${size}" -lt "${MIN_IMAGE_BYTES}" ]]; then
    echo "Image too small (${size} bytes at ${IMAGE_PATH}): incomplete download?" >&2
    exit 1
  fi

  if ! qemu-img info "${IMAGE_PATH}" >/dev/null 2>&1; then
    echo "Not a valid disk image: ${IMAGE_PATH}" >&2
    exit 1
  fi
}

install_tools() {
  if ! command -v virt-customize >/dev/null 2>&1; then
    log "Installing libguestfs-tools"
    apt-get update -y
    apt-get install -y --no-install-recommends libguestfs-tools
  fi
}

find_local_image() {
  local candidate
  for candidate in \
    "${IMAGE_PATH:-}" \
    "${SCRIPT_DIR}/${IMAGE_FILE}" \
    "${SCRIPT_DIR}/../${IMAGE_FILE}" \
    "${WORKDIR}/${IMAGE_FILE}"; do
    [[ -n "${candidate}" ]] || continue
    if image_is_valid "${candidate}"; then
      readlink -f "${candidate}"
      return 0
    fi
  done
  return 1
}

download_image() {
  IMAGE_PATH="${WORKDIR}/${IMAGE_FILE}"
  log "Downloading ${IMAGE_URL} -> ${IMAGE_PATH}"
  rm -f "${IMAGE_PATH}"
  wget -q --show-progress -O "${IMAGE_PATH}" "${IMAGE_URL}"
  validate_image
}

prepare_image() {
  if local_image="$(find_local_image)"; then
    IMAGE_PATH="${local_image}"
    log "Using existing image at ${IMAGE_PATH} ($(image_byte_size "${IMAGE_PATH}") bytes)"
    validate_image
    return
  fi

  warn "No valid local image found; downloading to ${WORKDIR}/${IMAGE_FILE}"
  download_image
}

customize_image() {
  log "Installing packages into cloud image: ${EXTRA_PACKAGES}"
  # Helps libguestfs on some Proxmox hosts
  export LIBGUESTFS_BACKEND="${LIBGUESTFS_BACKEND:-direct}"

  # shellcheck disable=SC2086
  if ! virt-customize -a "${IMAGE_PATH}" --install ${EXTRA_PACKAGES}; then
    echo "virt-customize failed. If libguestfs is broken on this host, set SKIP_VIRT_CUSTOMIZE=true in config.env and install qemu-guest-agent after first boot." >&2
    exit 1
  fi

  if [[ "${RUN_VIRT_SYSPREP}" == "true" ]]; then
    log "Running virt-sysprep (resets machine-id; never boot the VM before templating)"
    virt-sysprep -a "${IMAGE_PATH}"
  fi
}

import_disk_ref() {
  local vmid="$1"
  local import_output
  import_output="$(qm importdisk "${vmid}" "${IMAGE_PATH}" "${DISK_STORAGE}" 2>&1)"

  local disk_ref
  disk_ref="$(printf '%s\n' "${import_output}" | awk -F"'" '/successfully imported disk/ {print $2; exit}')"
  if [[ -z "${disk_ref}" ]]; then
    echo "Could not parse disk reference from qm importdisk output:" >&2
    printf '%s\n' "${import_output}" >&2
    exit 1
  fi

  log "Imported disk ${disk_ref}"
  printf '%s' "${disk_ref}"
}

create_template_vm() {
  local vmid="$1"
  local vm_name="${VM_NAME}"

  if [[ "${vmid}" != "${VMID}" ]]; then
    vm_name="${VM_NAME}-${vmid}"
  fi

  log "Creating VM ${vmid} (${vm_name})"
  qm create "${vmid}" \
    --name "${vm_name}" \
    --memory "${MEMORY}" \
    --cores "${CORES}" \
    --net0 "virtio,bridge=${BRIDGE}"

  local disk_ref
  disk_ref="$(import_disk_ref "${vmid}")"

  log "Attaching disk ${disk_ref}"
  qm set "${vmid}" --scsihw virtio-scsi-pci --scsi0 "${disk_ref}"
  qm set "${vmid}" --boot c --bootdisk scsi0
  qm set "${vmid}" --ide2 "${CLOUDINIT_STORAGE}:cloudinit"
  qm set "${vmid}" --serial0 socket --vga serial0
  qm set "${vmid}" --agent enabled=1

  if [[ -n "${TEMPLATE_DISK_SIZE}" ]]; then
    log "Growing template root disk by ${TEMPLATE_DISK_SIZE}"
    qm resize "${vmid}" scsi0 "${TEMPLATE_DISK_SIZE}"
  fi

  log "Converting VM ${vmid} to template"
  qm template "${vmid}"
}

main() {
  local effective_vmid
  effective_vmid="$(resolve_vmid)"

  install_tools
  prepare_image
  customize_image
  create_template_vm "${effective_vmid}"

  cat <<EOF

Template ready.

  VM ID:   ${effective_vmid}
  Name:    $(qm config "${effective_vmid}" | awk -F': ' '/^name: / {print $2; exit}')
  Image:   ${IMAGE_PATH}
  Storage: ${DISK_STORAGE} (disk), ${CLOUDINIT_STORAGE} (cloud-init)

Terraform clones this via template_map.ubuntu in modules/proxmox_vm/variables.tf.
Update that map to ${effective_vmid} if you want new VMs to use this template.
Default cloud-image login user is "ubuntu"; this repo sets users/SSH keys at clone time.

Quick test clone:
  qm clone ${effective_vmid} 9999 --name test-ubuntu-cloudinit --full 1
  qm set 9999 --sshkey ~/.ssh/id_ed25519.pub
  qm set 9999 --ipconfig0 ip=dhcp
  qm start 9999
  ssh ubuntu@<vm-ip>

Cleanup test VM:
  qm stop 9999 && qm destroy 9999

EOF
}

main "$@"
