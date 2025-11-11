# fresh start with proxmox 

- ssh a proxmox 
- generamos usuario para proxmox 
```zsh
# roles
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"

# user
pveum user add terraform-prov@pve --password <password>
pveum aclmod / -user terraform-prov@pve -role TerraformProv

# generar token
pveum user token add terraform-prov@pve caripa

```
```zsh
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL,SERIAL
```

```zsh
terraform init 

terraform fmt 

terraform validate


terraform plan -out=plan.tfplan  -var "do_token=${DO_PAT}"

terraform destroy -auto-approve

```
