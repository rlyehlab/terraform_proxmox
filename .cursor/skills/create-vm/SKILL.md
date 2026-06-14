---
name: create-vm
description: >-
  Create a new Proxmox VM layer in this Terraform repo (live/<node>/<vm>/),
  wire it to modules/proxmox_vm, and deploy with deploy.sh. Use when the user
  asks to add, create, or provision a VM, a new layer, or a new service on
  hydra/dunwitch.
---

# Create Proxmox VM

Add one Terraform root per VM under `live/<node>/<vm>/`. Each layer has its own S3 state key.

## Before starting

Gather or confirm:

| Input | Notes |
|-------|--------|
| `node` | Proxmox node: `hydra`, `dunwitch`, … |
| `vm` | Layer folder name (kebab-case), e.g. `my-service` |
| `vm_id` | Unique on that node (100–9999). Check with `qm list` on Proxmox |
| `template_name` | Key from `template_map`: `ubuntu`, `debian`, `alpine`, `fedora` |
| `vm_user` | Linux login (not `root` unless intentional). Default pattern: `user` |
| `network_bridge` | Usually `vmbr1` (production); `vmbr2` for datasyn stack |
| `ipv4_address` | Static CIDR (e.g. `10.69.69.119/24`) or omit/`dhcp` |
| `ipv4_gateway` | Gateway when static (e.g. `10.69.69.1`) |
| `ssh_keys` | Public keys in `env.auto.tfvars` (committed) |

**Prerequisites**

- Cloud-init template exists on Proxmox (`create_template/ubuntu/create-template.sh` if missing)
- Node secrets: `live/<node>/env.secrets.auto.tfvars` (gitignored; copy from `.example`)
- AWS credentials for S3 backend `rlab-tfstate`
- For custom cloud-init (`use_cloud_init_user_data = true`): SSH to Proxmox via agent or `proxmox_ssh_password`

## Workflow

```
Task Progress:
- [ ] Step 1: Pick reference layer and vm_id
- [ ] Step 2: Create live/<node>/<vm>/ files
- [ ] Step 3: Fill env.auto.tfvars
- [ ] Step 4: terraform init + plan
- [ ] Step 5: Apply and verify SSH
```

### Step 1: Pick reference layer

| Pattern | Copy from | When |
|---------|-----------|------|
| **Standard** | `live/hydra/pad/` | Proxmox `user_account` SSH keys; module default `template_map` |
| **Custom cloud-init** | `live/hydra/datasyn-agent/` | Custom `#cloud-config` snippet; node-specific `template_map` in `locals.tf`; SSH keys in `locals.tf` |

### Step 2: Create layer files

From repo root, copy the reference layer:

```bash
NODE=hydra
VM=my-service
cp -R live/hydra/pad live/${NODE}/${VM}
rm -f live/${NODE}/${VM}/tfplan live/${NODE}/${VM}/.terraform.lock.hcl
rm -rf live/${NODE}/${VM}/.terraform
```

Edit these files (do **not** skip `backend.hcl` — state key must be unique):

**`backend.hcl`** — unique state key per VM:

```hcl
bucket  = "rlab-tfstate"
key     = "proxmox/<node>/<vm>/terraform.tfstate"
region  = "us-east-1"
encrypt = true
```

**`main.tf`** — call `module "vm"` with required inputs. Minimum:

```hcl
module "vm" {
  source = "../../../modules/proxmox_vm"

  proxmox_node_name = var.node_name
  password          = var.password
  vm_name           = var.vm_name
  memory            = var.memory
  vm_id             = var.vm_id
  cores             = var.cores
  disk_size         = var.disk_size
  template_name     = var.template_name
  tags              = var.tags
  vm_user           = var.vm_user
  ssh_keys          = var.ssh_keys
  ipv4_address      = var.ipv4_address
  ipv4_gateway      = var.ipv4_gateway
  network_bridge    = var.network_bridge
}
```

Optional module args: `network_bridge`, `use_cloud_init_user_data`, `template_map` (from `locals.tf`).

**`providers.tf`**, **`variables.tf`** — keep identical to reference layer unless the VM needs extra variables (e.g. `network_bridge`, `use_cloud_init_user_data`).

For **custom cloud-init**, add `locals.tf`:

```hcl
locals {
  template_map = {
    ubuntu = 6013   # node-specific template VM ID
    debian = 6010
    alpine = 6011
    fedora = 6012
  }
  ssh_keys = [ /* ... */ ]
}
```

And in `main.tf`: `template_map = local.template_map`, `ssh_keys = local.ssh_keys`, `use_cloud_init_user_data = true`.

### Step 3: Fill `env.auto.tfvars`

```hcl
vm_name        = "My-Service"
memory         = 2048
vm_id          = 119
network_bridge = "vmbr2"
ipv4_address   = "10.69.69.119/24"
ipv4_gateway   = "10.69.69.1"
cores          = 2
disk_size      = 20           # GB; null = template size
template_name  = "ubuntu"
network_bridge = "vmbr1"       # vmbr2 for datasyn; see live/<node>/ip-allocations.yaml
tags           = ["terraform", "ubuntu", "production"]
vm_user        = "user"
ssh_keys = [
  "ssh-ed25519 AAAA... comment",
]
```

Secrets stay in `live/<node>/env.secrets.auto.tfvars` — never commit.

Register the IP in `live/<node>/ip-allocations.yaml` before apply.

### Step 4: Init and plan

From repo root:

```bash
bash .github/scripts/deploy.sh terraform-init  <node>/<vm>
bash .github/scripts/deploy.sh terraform-plan  <node>/<vm>
```

Raw Terraform (if needed):

```bash
cd live/<node>/<vm>
terraform init -reconfigure -backend-config=backend.hcl
terraform plan -var-file=../env.secrets.auto.tfvars -out=tfplan
```

Review plan: expect **create** (new VM) or **update in-place** (existing). **Never apply** a plan that **replaces** the VM unless intentional.

### Step 5: Apply and verify

```bash
bash .github/scripts/deploy.sh terraform-apply <node>/<vm>
```

**SSH check**

- User is `vm_user` from `env.auto.tfvars` (e.g. `user`), not `root`
- Use the private key matching a public key in `ssh_keys` / `locals.tf`
- Find IP: `ipv4_address` in `env.auto.tfvars`, or on Proxmox `qm guest cmd <vm_id> network-get-interfaces` (DHCP)

```bash
ssh -i ~/.ssh/<matching-key> -o IdentitiesOnly=yes <vm_user>@<vm-ip>
```

## Existing VM on Proxmox (vm_id already taken)

If the VM exists but is not in Terraform state:

```bash
cd live/<node>/<vm>
terraform import -var-file=../env.secrets.auto.tfvars \
  module.vm.proxmox_virtual_environment_vm.vm_clone <node_name>/<vm_id>
terraform plan -var-file=../env.secrets.auto.tfvars
```

Apply only in-place changes. Module uses `lifecycle { ignore_changes = [clone] }` so imported VMs are not recreated.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `env.secrets.auto.tfvars does not exist` | `cp live/<node>/env.secrets.auto.tfvars.example live/<node>/env.secrets.auto.tfvars` |
| `config file already exists` (vm_id) | Import existing VM (above) or pick a free `vm_id` |
| SSH asks for password | Wrong user (`root` vs `vm_user`) or wrong key; cloud-init keys are on `vm_user` only |
| Snippet upload fails | Proxmox SSH: `ssh-add` key for `root@<proxmox-host>` or set `proxmox_ssh_password` |
| QEMU agent timeout on apply | Often harmless; VM may still be booting. Retry `qm guest cmd` after 1–2 min |

## Optional follow-ups

- Update `README.md` node VM table if adding a production service
- CI auto-detects new layers via `live/<node>/<vm>/main.tf` — no workflow change needed
- Module changes (`modules/proxmox_vm/**`) affect **all** VMs on next CI run

## Reference

- Layer examples: `live/hydra/pad/` (standard), `live/hydra/datasyn-agent/` (custom cloud-init)
- Module: `modules/proxmox_vm/`
- Deploy helper: `.github/scripts/deploy.sh`
- Template builder: `create_template/ubuntu/create-template.sh`

For file templates and variable lists, see [reference.md](reference.md).
