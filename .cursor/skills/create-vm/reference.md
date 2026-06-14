# Create VM — Reference

## Layer file checklist

Each VM layer needs:

| File | Purpose |
|------|---------|
| `main.tf` | `module "vm"` block |
| `providers.tf` | Terraform backend (partial S3) + bpg/proxmox provider |
| `backend.hcl` | Unique `key = "proxmox/<node>/<vm>/terraform.tfstate"` |
| `variables.tf` | Provider secrets vars + VM input vars |
| `env.auto.tfvars` | VM config (committed): name, id, keys, tags, … |
| `locals.tf` | Optional: `template_map`, `ssh_keys` (datasyn pattern) |

Node-level (once per Proxmox node):

| File | Purpose |
|------|---------|
| `live/<node>/env.secrets.auto.tfvars` | API URL, token, passwords (gitignored) |
| `live/<node>/env.secrets.auto.tfvars.example` | Template for secrets |

## Module inputs (common)

| Variable | Default | Layer override |
|----------|---------|----------------|
| `template_name` | `ubuntu` | `env.auto.tfvars` |
| `template_map` | 6009–6012 | `locals.tf` on some nodes |
| `network_bridge` | `vmbr1` (production) or `vmbr2` (datasyn) | `env.auto.tfvars` |
| `ipv4_address` | CIDR per `live/<node>/ip-allocations.yaml` | `env.auto.tfvars` |
| `ipv4_gateway` | `10.13.10.1` (vmbr1) or `10.69.69.1` (vmbr2) | `env.auto.tfvars` |
| `disk_size` | `null` | GB; grow root disk |
| `use_cloud_init_user_data` | `false` | `true` for custom snippet |
| `vm_user` | `admin` | Usually `user` |
| `datastore_id` | `tank` | Disk storage |
| `initialization_datastore_id` | `local-lvm` | Cloud-init drive |

## providers.tf pattern

Copy from `live/hydra/pad/providers.tf` unchanged unless adding a new node name default in `variables.tf`.

Provider SSH block is required for snippet uploads (`proxmox_virtual_environment_file`).

## Standard vs custom cloud-init

**Standard** (`use_cloud_init_user_data = false`):

- SSH keys via Proxmox `initialization.user_account.keys`
- Password via `initialization.user_account.password`

**Custom** (`use_cloud_init_user_data = true`):

- Snippet from `modules/proxmox_vm/cloud_init.tf` uploaded to Proxmox
- Creates `vm_user` with `ssh_authorized_keys` and `chpasswd`
- Proxmox `user_account.username` set to `vm_user`; keys empty (snippet owns auth)
- Requires Proxmox root SSH for upload

## Template VM IDs (hydra example)

| OS | template_name | VM ID (datasyn locals) |
|----|---------------|------------------------|
| Ubuntu 20.04 | ubuntu | 6013 |
| Debian | debian | 6010 |
| Alpine | alpine | 6011 |
| Fedora | fedora | 6012 |

Module defaults use 6009 for ubuntu — override with `template_map` when node differs.

## Deploy commands

```bash
# From repo root
bash .github/scripts/deploy.sh terraform-init  <node>/<vm>
bash .github/scripts/deploy.sh terraform-plan  <node>/<vm>
bash .github/scripts/deploy.sh terraform-apply <node>/<vm>

# Detect affected layers after git changes
bash .github/scripts/deploy.sh detect-layers HEAD~1 HEAD
```

## Import command

```bash
terraform import -var-file=../env.secrets.auto.tfvars \
  module.vm.proxmox_virtual_environment_vm.vm_clone <node>/<vm_id>
```

Example: `hydra/118`
