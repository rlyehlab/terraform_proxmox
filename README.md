# Terraform Proxmox

Terraform setup to spin up VMs on Proxmox using the [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/) provider.

## Repository Layout

```
env/
  hydra/       # Proxmox node: hydra
  dunwitch/    # Proxmox node: dunwitch
modules/
  proxmox_vm/  # Reusable VM module
```

Each env is an independent Terraform root. The tfstate lives in an S3 bucket — ask the admin for AWS credentials before doing anything.

## Prerequisites

- Terraform installed
- AWS CLI configured (for S3 backend)
- SSH agent running with the `tf` key loaded

## Proxmox Setup

SSH into the Proxmox node and run this once to create the provisioner user and token:

```zsh
# create role
pveum role add Provisioner -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"

# create user and assign role
pveum user add tf@pve --password <password>
pveum aclmod / -user tf@pve -role Provisioner

# generate token (no privilege separation)
pveum user token add tf@pve caripa-token --privsep 0
```

## Cloud Init

We use cloud-init to handle VM initialization — SSH keys, user accounts, disk mounts, etc. You need a cloud-init enabled template VM on Proxmox before running Terraform. [This tutorial](https://github.com/UntouchedWagons/Ubuntu-CloudInit-Docs) covers the Ubuntu setup.

### VM User & SSH Access

Users and SSH keys are provisioned at VM creation time via cloud-init — nothing is hardcoded in the template. This makes it easy to rotate team access without rebuilding templates.

Set these in your `env.auto.tfvars`:

```hcl
vm_user  = "admin"
ssh_keys = [
  "ssh-ed25519 AAAA... alice@laptop",
  "ssh-ed25519 AAAA... bob@laptop",
]
```

When someone joins or leaves the team, update `ssh_keys` and reprovision the affected VMs.

> SSH keys go in `env.auto.tfvars`, not `env.secrets.auto.tfvars` — they are not secrets. Only tokens and passwords belong in the secrets file.

## Usage

```zsh
cd env/hydra  # or env/dunwitch

terraform init

terraform fmt

terraform validate

terraform plan -out=plan.tfplan

terraform apply "plan.tfplan"

terraform destroy -auto-approve
```

> `.auto.tfvars` files are loaded automatically — no need to pass `-var-file`.

## Nuclear Option

If a VM goes rogue, destroy it directly from the Proxmox node:

```zsh
qm destroy <vm-id>
```

## References

- https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/
- https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/