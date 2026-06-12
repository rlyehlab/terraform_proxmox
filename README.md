# 🖥️ Terraform Proxmox

> Infrastructure-as-code for Proxmox VMs — one Terraform state per VM, shared module, S3 remote backend, and git-diff driven CI/CD.

![Architecture diagram](docs/architecture.svg)

## 🧭 At a Glance

| Concept | Description |
|---|---|
| **Layer** | One VM = one Terraform root under `live/<node>/<vm>/` |
| **Module** | `modules/proxmox_vm` — clone, cloud-init, disk resize |
| **State** | Shared bucket `rlab-tfstate`, unique S3 key per VM |
| **CI** | GitHub Actions plans/applies only changed VMs |
| **Secrets** | Node-level `env.secrets.auto.tfvars` (not committed) |

**Proxmox nodes today**

| Node | VMs | State keys |
|---|---|---|
| `hydra` | pad, wiki, nextcloud, controller, grafana, datasyn-agent | `proxmox/hydra/<vm>/terraform.tfstate` |
| `dunwitch` | testing | `proxmox/dunwitch/testing/terraform.tfstate` |

---

## 📁 Repository Layout

```
terraform_proxmox-1/
├── docs/
│   └── architecture.svg          # 📊 Architecture diagram (this repo)
├── live/                         # 🌍 Terraform roots — one per VM
│   ├── hydra/
│   │   ├── pad/
│   │   ├── wiki/
│   │   ├── nextcloud/
│   │   ├── controller/
│   │   ├── grafana/
│   │   ├── datasyn-agent/
│   │   └── env.secrets.auto.tfvars.example
│   └── dunwitch/
│       ├── testing/
│       └── env.secrets.auto.tfvars.example
├── modules/
│   └── proxmox_vm/               # 🧩 Reusable VM module
├── .github/
│   ├── scripts/
│   │   ├── deploy.sh             # init · plan · apply · detect-layers
│   │   └── detect-layers.sh      # git-diff → CI matrix
│   └── workflows/
│       └── deploy.yml            # PR plan · main apply
├── scripts/
│   └── migrate-state.sh          # 🔀 Split legacy monolithic state
└── create_template/              # 🛠️ Manual Proxmox template builder
```

Each VM layer contains:

| File | Role |
|---|---|
| `main.tf` | Calls `module "vm"` |
| `providers.tf` | Proxmox provider + partial S3 backend |
| `backend.hcl` | Bucket + **unique** state key |
| `variables.tf` | Provider + VM inputs |
| `env.auto.tfvars` | VM config (name, id, ssh_keys, …) |

---

## 🏗️ Architecture

### Data flow

1. **Developer** or **GitHub Actions** runs Terraform against a single VM layer (e.g. `live/hydra/pad/`).
2. The layer reads **node secrets** from `live/hydra/env.secrets.auto.tfvars` (local or via `TF_VAR_*` in CI).
3. Terraform loads **remote state** from `s3://rlab-tfstate/proxmox/hydra/pad/terraform.tfstate`.
4. The shared **`modules/proxmox_vm`** module talks to the Proxmox API and clones a template VM.
5. **Cloud-init** provisions users, SSH keys, and optional custom snippets (datasyn-agent).

See the full visual overview: **[docs/architecture.svg](docs/architecture.svg)**

### Why one state per VM?

| Before (`env/hydra`) | After (`live/hydra/<vm>`) |
|---|---|
| 1 `apply` touched all 6 VMs | Change grafana → only grafana plans |
| Large blast radius | Independent lifecycle per service |
| Slow plans | Targeted CI matrix |

---

## ✅ Prerequisites

- 🧱 **Terraform** >= 1.5
- ☁️ **AWS CLI** configured (S3 backend access)
- 🔑 **SSH agent** with `tf` key (for cloud-init snippet uploads)
- 🖧 **Proxmox** API token + `tf@pve` user (see setup below)

---

## 🔧 Proxmox Setup (one-time)

SSH into the Proxmox node:

```zsh
# 1️⃣ Create provisioner role
pveum role add Provisioner -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"

# 2️⃣ Create Terraform user
pveum user add tf@pve --password <password>
pveum aclmod / -user tf@pve -role Provisioner

# 3️⃣ Generate API token (no privilege separation)
pveum user token add tf@pve caripa-token --privsep 0
```

---

## ☁️ Cloud-Init

Cloud-init handles VM bootstrap: SSH keys, users, DNS, disk config. You need a **cloud-init enabled template** on Proxmox before running Terraform.

📖 Ubuntu guide: [Ubuntu-CloudInit-Docs](https://github.com/UntouchedWagons/Ubuntu-CloudInit-Docs)

### 👤 VM users & SSH keys

Set per-VM values in `env.auto.tfvars`:

```hcl
vm_user  = "admin"
ssh_keys = [
  "ssh-ed25519 AAAA... alice@laptop",
  "ssh-ed25519 AAAA... bob@laptop",
]
```

> ⚠️ **Important:** SSH keys live in `env.auto.tfvars` (committed). Only tokens and passwords go in secrets files.

### 🤖 datasyn-agent (custom cloud-init)

Requires:

1. `Datastore.Allocate` on the Provisioner role
2. `proxmox_ssh_password` in `live/hydra/env.secrets.auto.tfvars` **or** SSH agent with `root@<proxmox-host>` access

Uses template VM **6013** and uploads a custom `#cloud-config` snippet.

---

## 🚀 Usage

### 1️⃣ Configure secrets (once per node)

```zsh
cp live/hydra/env.secrets.auto.tfvars.example live/hydra/env.secrets.auto.tfvars
# Edit: proxmox_api_url, proxmox_api_token, password, proxmox_ssh_password
```

### 2️⃣ Deploy a single VM

**Option A — deploy helper (recommended)**

```zsh
bash .github/scripts/deploy.sh terraform-init  hydra/pad
bash .github/scripts/deploy.sh terraform-plan  hydra/pad
bash .github/scripts/deploy.sh terraform-apply hydra/pad
```

**Option B — raw Terraform**

```zsh
cd live/hydra/pad
terraform init -backend-config=backend.hcl
terraform plan  -var-file=../env.secrets.auto.tfvars -out=plan.tfplan
terraform apply plan.tfplan
```

### 3️⃣ Detect which VMs changed

```zsh
bash .github/scripts/deploy.sh detect-layers HEAD~1 HEAD
```

Example output:

```json
["hydra/pad"]
```

### 🔍 Change detection rules

| What changed | VMs deployed |
|---|---|
| `modules/proxmox_vm/**` | ⚡ **All VMs** (module blast radius) |
| `live/hydra/pad/**` | `hydra/pad` only |
| `live/hydra/env.secrets.auto.tfvars` | All VMs on **hydra** |
| `live/dunwitch/testing/**` | `dunwitch/testing` only |
| Invalid git SHAs | All VMs (safe default) |

Pattern inspired by [ubika-infra](https://github.com/ubika/ubika-infra).

---

## 🤖 CI/CD

Workflow: `.github/workflows/deploy.yml`

| Event | Action |
|---|---|
| 📬 Pull request | `terraform plan` on changed VMs |
| 🚀 Push to `main` | `terraform apply` on changed VMs |
| 🎯 `workflow_dispatch` | Deploy one VM via `layer` input (e.g. `hydra/pad`) |

### Required GitHub secrets

| Secret | Purpose |
|---|---|
| `AWS_ROLE_ARN` | OIDC → S3 backend |
| `PROXMOX_API_URL` | Proxmox API endpoint |
| `PROXMOX_API_TOKEN` | Token (`id=secret`) |
| `PROXMOX_PASSWORD` | `tf@pve` password |
| `PROXMOX_SSH_PASSWORD` | Root SSH for snippet uploads |

> 💡 Deploys run with `max-parallel: 1` to avoid Proxmox API races on the same node.

---

## 🔀 State Migration

If you still have a legacy monolithic state at `proxmox/hydra/terraform.tfstate`:

```zsh
./scripts/migrate-state.sh hydra pad hydra/pad
./scripts/migrate-state.sh hydra wiki hydra/wiki
# … repeat for each VM
```

Manual alternative:

```zsh
cd live/hydra/pad
terraform init -backend-config=backend.hcl
terraform state mv 'module.pad.proxmox_virtual_environment_vm.vm_clone' \
                   'module.vm.proxmox_virtual_environment_vm.vm_clone'
```

Remove each VM from the old root until the legacy state is empty.

---

## 💥 Nuclear Option

Destroy a VM directly on Proxmox (bypasses Terraform):

```zsh
qm destroy <vm-id>
```

---

## 📚 References

- [Create a Proxmox Ubuntu cloud-init image](https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/)
- [Deploy VMs in Proxmox with Terraform](https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/)
- [bpg/proxmox provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
