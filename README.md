# Terraform Proxmox

Infrastructure-as-code for virtual machines on [Proxmox VE](https://www.proxmox.com/). Each VM is a separate Terraform root with its own remote state, a shared reusable module, and CI that only plans/applies what changed in git.

![Infrastructure diagram](docs/architecture.svg)

---

## What is this repository?

This repo manages **Proxmox VMs as code**. It does not install application software inside VMs — it provisions the machines (CPU, RAM, disk, network, cloud-init, SSH keys).

| Concept | Meaning |
|---------|---------|
| **Layer** | One VM = one folder under `live/<node>/<vm>/` |
| **Node** | A Proxmox host (e.g. `hydra`, `dunwitch`) |
| **Module** | `modules/proxmox_vm` — clone template, resize disk, cloud-init |
| **State** | S3 bucket `rlab-tfstate`, one key per VM |
| **Secrets** | Node file `live/<node>/env.secrets.auto.tfvars` (not committed) |
| **Config** | Per-VM `env.auto.tfvars` (name, vm_id, cores, disk, …) |

**Why one state per VM?** Changing one service only plans/applies that VM. Module changes still roll out to all VMs (shared code).

---

## Initial setup

Do this once before your first local deploy.

### 1. Install local tools

See [Local requirements](#local-requirements) below, or use the [setup prompt](#setup-prompt-for-ai-assistant) to install everything on a fresh machine.

### 2. Clone the repository

```bash
git clone https://github.com/rlyehlab/terraform_proxmox.git
cd terraform_proxmox
```

### 3. Configure AWS (S3 backend)

Terraform stores state in `s3://rlab-tfstate`. Your AWS credentials need read/write access to that bucket.

```bash
aws configure
# or export AWS_PROFILE / AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
aws sts get-caller-identity   # verify access
```

### 4. Configure Proxmox secrets (per node)

```bash
cp live/hydra/env.secrets.auto.tfvars.example live/hydra/env.secrets.auto.tfvars
```

Edit `live/hydra/env.secrets.auto.tfvars`:

```hcl
proxmox_api_url      = "https://<proxmox-host>:8006"
proxmox_api_token    = "tf@pve!token-name=<secret>"
password             = "<tf@pve password>"
proxmox_ssh_password = ""   # leave empty if using ssh-agent for root@proxmox
```

Repeat for other nodes (`live/dunwitch/`, …) when you deploy there.

### 5. Proxmox one-time setup (on the node)

Run on the Proxmox host via SSH:

```bash
# Provisioner role
pveum role add Provisioner -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"

# Terraform API user
pveum user add tf@pve --password '<password>'
pveum aclmod / -user tf@pve -role Provisioner
pveum user token add tf@pve terraform-token --privsep 0
```

Cloud-init **templates** must exist on Proxmox before cloning VMs. Build them with `create_template/ubuntu/create-template.sh` if missing.

### 6. Deploy a VM

```bash
bash .github/scripts/deploy.sh terraform-init  hydra/pad
bash .github/scripts/deploy.sh terraform-plan  hydra/pad
bash .github/scripts/deploy.sh terraform-apply hydra/pad
```

Replace `hydra/pad` with any layer under `live/` that has a `main.tf`.

---

## Local requirements

| Tool | Version | Purpose |
|------|---------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.5 | Plan and apply infrastructure |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | v2 | S3 remote state authentication |
| [Git](https://git-scm.com/) | any recent | Clone repo, CI change detection |
| [jq](https://jqlang.github.io/jq/) | any | `detect-layers` JSON output |
| SSH client + agent | — | Optional: upload cloud-init snippets to Proxmox as `root` |

**Access you need**

- AWS credentials with access to bucket `rlab-tfstate` (region `us-east-1`)
- Proxmox API token for user `tf@pve`
- Network reachability to Proxmox API (`https://<host>:8006`)
- SSH key matching a public key in the VM layer (`env.auto.tfvars` or `locals.tf`)

**Verify**

```bash
terraform version
aws --version
aws sts get-caller-identity
```

---

## Setup prompt (for AI assistant)

Copy the block below into Cursor, ChatGPT, or another assistant on a **new machine** to install prerequisites and validate the environment for this project:

```text
I need to run the Terraform Proxmox repo locally on macOS (or Linux). Help me install and verify everything.

Project context:
- Repo: terraform_proxmox — one Terraform root per VM under live/<node>/<vm>/
- Remote state: AWS S3 bucket rlab-tfstate, region us-east-1
- Tools used: Terraform >= 1.5, AWS CLI v2, git, jq, bash
- Deploy helper: bash .github/scripts/deploy.sh terraform-init|plan|apply <node>/<vm>
- Secrets file (not in git): live/hydra/env.secrets.auto.tfvars with proxmox_api_url, proxmox_api_token, password, optional proxmox_ssh_password

Please:
1. Detect my OS and package manager (Homebrew on macOS, apt/dnf on Linux).
2. Install Terraform (>= 1.5), AWS CLI v2, git, and jq if missing.
3. Show how to configure AWS credentials (aws configure or env vars) and verify with aws sts get-caller-identity.
4. Show how to clone the repo and copy live/hydra/env.secrets.auto.tfvars.example to env.secrets.auto.tfvars.
5. Run terraform version and a dry terraform init for one layer, e.g. hydra/pad, using:
   bash .github/scripts/deploy.sh terraform-init hydra/pad
6. List anything still missing (Proxmox token, VPN, SSH agent) that I must provide manually.

Do not commit secrets. Use placeholders in examples.
```

---

## Infrastructure

![Infrastructure diagram](docs/architecture.svg)

### Flow

1. **Developer** or **GitHub Actions** runs Terraform for one layer (`live/<node>/<vm>/`).
2. Layer loads **node secrets** from `live/<node>/env.secrets.auto.tfvars`.
3. Terraform reads/writes **remote state** at `s3://rlab-tfstate/proxmox/<node>/<vm>/terraform.tfstate`.
4. Shared module **`modules/proxmox_vm`** calls the Proxmox API, full-clones a template, applies cloud-init.
5. VM boots with configured user, SSH keys, disk, and network bridge.

### Repository layout

```
terraform_proxmox/
├── live/<node>/<vm>/     # One Terraform root per VM
│   ├── main.tf           # module "vm" { ... }
│   ├── backend.hcl       # Unique S3 state key
│   ├── env.auto.tfvars   # VM sizing, vm_id, tags
│   └── providers.tf
├── live/<node>/env.secrets.auto.tfvars   # gitignored
├── modules/proxmox_vm/   # Shared VM module
├── .github/scripts/deploy.sh
└── create_template/      # Build cloud-init templates on Proxmox
```

### Proxmox nodes

| Node | Layers | State key pattern |
|------|--------|-------------------|
| `hydra` | Multiple VMs under `live/hydra/*/` | `proxmox/hydra/<vm>/terraform.tfstate` |
| `dunwitch` | `testing` | `proxmox/dunwitch/testing/terraform.tfstate` |

---

## Day-to-day usage

### Plan / apply one VM

```bash
bash .github/scripts/deploy.sh terraform-init  hydra/grafana
bash .github/scripts/deploy.sh terraform-plan  hydra/grafana
bash .github/scripts/deploy.sh terraform-apply hydra/grafana
```

### See which layers changed (CI logic)

```bash
bash .github/scripts/deploy.sh detect-layers HEAD~1 HEAD
```

| Change | Effect |
|--------|--------|
| `modules/proxmox_vm/**` | All VMs planned in CI |
| `live/hydra/<vm>/**` | That VM only |
| `live/hydra/env.secrets.auto.tfvars` | All VMs on `hydra` |

### SSH into a new VM

User is `vm_user` from `env.auto.tfvars` (usually `user`), not `root`.

```bash
# On Proxmox
qm guest cmd <vm_id> network-get-interfaces

# From your laptop (key must match layer ssh_keys / locals.tf)
ssh -i ~/.ssh/<key> -o IdentitiesOnly=yes user@<vm-ip>
```

---

## CI/CD

Workflow: `.github/workflows/deploy.yml`

| Event | Action |
|-------|--------|
| Pull request | `terraform plan` on changed layers |
| Push to `main` | `terraform apply` on changed layers |
| `workflow_dispatch` | Deploy one layer via input `layer` |

GitHub secrets: `AWS_ROLE_ARN`, `PROXMOX_API_URL`, `PROXMOX_API_TOKEN`, `PROXMOX_PASSWORD`, `PROXMOX_SSH_PASSWORD`.

---

## Adding a new VM

Use the Cursor skill at `.cursor/skills/create-vm/SKILL.md`, or copy an existing layer:

```bash
cp -R live/hydra/pad live/hydra/my-service
# Edit backend.hcl (unique state key), env.auto.tfvars (vm_id, disk, …)
bash .github/scripts/deploy.sh terraform-init  hydra/my-service
bash .github/scripts/deploy.sh terraform-plan  hydra/my-service
```

Pick a free `vm_id` on the target node (`qm list` on Proxmox).

---

## References

- [bpg/proxmox Terraform provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Proxmox cloud-init Ubuntu image](https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/)
- [Deploy VMs in Proxmox with Terraform](https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/)
