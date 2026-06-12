# Proxmox VM templates

Scripts to build cloud-init enabled templates on Proxmox for use with this repo's Terraform modules.

## Blog post summary

[Austin's guide](https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/) builds a reusable Ubuntu template in six steps:

| Step | Action | Why |
|------|--------|-----|
| 1 | Download official Ubuntu **cloud image** (`.img`) | Pre-built for cloud-init; no ISO install |
| 2 | `virt-customize` packages into the image (e.g. `qemu-guest-agent`) | Guest agent is required for Terraform IP discovery and clean shutdown |
| 3 | `qm create` + `qm importdisk` + attach `scsi0`, `ide2` cloud-init, serial console | Proxmox VM skeleton with boot disk and cloud-init drive |
| 4 | `qm template` | Marks VM as clone source; do **not** boot first (duplicate `machine-id` / DHCP issues) |
| 5 | `qm clone` + `qm set --sshkey` / `--ipconfig0` | Per-VM SSH keys and networking at clone time |
| 6 | Automate with a shell script | Refresh template on a schedule |

### Important notes from the post and comments

- **Default login user** on Ubuntu cloud images is `ubuntu`, not your SSH key username.
- **Do not boot** the template VM before `qm template`; booting assigns a `machine-id` that clones inherit. Use `virt-sysprep` or stay unbooted.
- **Enable guest agent** on the VM (`--agent enabled=1`) after baking `qemu-guest-agent` into the image.
- **Disk size**: cloud images are ~2–3 GB; expand with `qm resize` on clone or template if apt/boot fails.
- **Storage syntax** varies by backend (`local-zfs:vm-9000-disk-0` vs `ext8tb1:9000/vm-9000-disk-0.raw`); parse `qm importdisk` output.
- **libguestfs on Proxmox** can segfault on some versions; install with `--no-install-recommends` or run customization off-node.

## This repository

| Template | VM ID | Script |
|----------|-------|--------|
| `ubuntu` | 6009 | [`ubuntu/create-template.sh`](ubuntu/create-template.sh) |
| `debian` | 6010 | (manual / separate) |

Defaults in `ubuntu/config.env.example` match [`modules/proxmox_vm/variables.tf`](../modules/proxmox_vm/variables.tf):

- Disk datastore: `tank`
- Cloud-init drive: `local-lvm`
- Snippets (Terraform user-data): `local`

## Create Ubuntu template

SSH to the Proxmox node (e.g. `hydra`) as root:

```bash
cd template/ubuntu
cp config.env.example config.env   # edit VMID, storage, Ubuntu release if needed
chmod +x create-template.sh
./create-template.sh
```

The script will:

1. Use the configured VM ID if it is free; otherwise keep the existing template and create a new one on the next free ID
2. Download the Focal 20.04 cloud image (configurable)
3. Install `qemu-guest-agent` and run `virt-sysprep`
4. Import the disk, attach cloud-init, enable serial console + agent
5. Grow the root disk to ~8 GB and convert to template

After creation, update `template_map.ubuntu` in `modules/proxmox_vm/variables.tf` if the script picked a new VM ID. Terraform VMs with `template_name = "ubuntu"` clone from that ID (default **6009**).

## Verify a clone

```bash
qm clone 6009 9999 --name test-ubuntu-cloudinit --full 1
qm set 9999 --sshkey ~/.ssh/id_ed25519.pub
qm set 9999 --ipconfig0 ip=dhcp
qm start 9999
ssh ubuntu@<vm-ip>
qm stop 9999 && qm destroy 9999
```

For production VMs, use Terraform (`env/hydra`, `template_name = "ubuntu"`) so users, SSH keys, and disk size are managed in code.

## References

- https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/
- https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/
- https://cloud-images.ubuntu.com/
