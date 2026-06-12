#!/usr/bin/env bash
set -euo pipefail

# One-time helper: split a monolithic env/<node> state into per-VM live/<node>/<vm> states.
#
# Usage:
#   ./scripts/migrate-state.sh <node> <old_module_name> <new_layer>
#
# Example:
#   ./scripts/migrate-state.sh hydra pad hydra/pad
#
# Prerequisites:
#   - Old state still at s3://rlab-tfstate/proxmox/<node>/terraform.tfstate
#   - New layer already created under live/<node>/<vm>/

NODE="${1:?node required (e.g. hydra)}"
OLD_MODULE="${2:?old module name required (e.g. pad)}"
NEW_LAYER="${3:?new layer required (e.g. hydra/pad)}"

OLD_DIR="$(mktemp -d)"
NEW_DIR="live/$NEW_LAYER"
OLD_STATE_KEY="proxmox/$NODE/terraform.tfstate"

if [[ ! -f "$NEW_DIR/main.tf" ]]; then
  echo "Missing $NEW_DIR/main.tf"
  exit 1
fi

echo "==> Pulling old state from s3://rlab-tfstate/$OLD_STATE_KEY"
aws s3 cp "s3://rlab-tfstate/$OLD_STATE_KEY" "$OLD_DIR/terraform.tfstate"

echo "==> Initializing new layer $NEW_LAYER"
bash .github/scripts/deploy.sh terraform-init "$NEW_LAYER"

echo "==> Importing module.$OLD_MODULE resources into live/$NEW_LAYER"
pushd "$NEW_DIR" >/dev/null
terraform init -reconfigure -backend-config=backend.hcl -input=false

# Move VM resource (adjust address if your old module used a different resource name)
terraform state mv \
  -state="$OLD_DIR/terraform.tfstate" \
  -state-out=terraform.tfstate \
  "module.$OLD_MODULE.proxmox_virtual_environment_vm.vm_clone" \
  "module.vm.proxmox_virtual_environment_vm.vm_clone" || true

# Move optional cloud-init snippet if present
terraform state mv \
  -state="$OLD_DIR/terraform.tfstate" \
  -state-out=terraform.tfstate \
  "module.$OLD_MODULE.proxmox_virtual_environment_file.cloud_init_user_data[0]" \
  "module.vm.proxmox_virtual_environment_file.cloud_init_user_data[0]" || true

terraform state push terraform.tfstate
popd >/dev/null

echo "==> Done. Verify with: bash .github/scripts/deploy.sh terraform-plan $NEW_LAYER"
echo "    Then remove module \"$OLD_MODULE\" from the old env/$NODE root and repeat for other VMs."
