# fresh start with proxmox 

1. generacion de usuario y token

- ssh a proxmox 

- generamos usuario para proxmox 
```zsh
# generamos el rol
pveum role add Provisioner -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"

# user
pveum user add tf@pve --password <password>
pveum aclmod / -user tf@pve -role Provisioner

# generar token sin separaciond e privilegios 
pveum user token add tf@pve caripa-token --privsep 0

```

1. Cloud init
en este caso vamos a usar ubuntu cloud y voy a usar [este](https://github.com/UntouchedWagons/Ubuntu-CloudInit-Docs) tutorial
cloud init es basicamente un agente que nos ayuda a configurar el init de las nuevas vms que queramos levantar, agregando ssh, configuraciones basicas de user y pass, montar discos, y tratar de lograr una automatizacion del init al generar nueva vm. para esto tenemos que tener una vm para configurar.

1. provider 
vamos a utilizar [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/)
el de telmate/proxmox es una poronga.


1. terraform 
```zsh
terraform init 

terraform fmt 

terraform validate

terraform plan -out=plan.tfplan -var-file="env.tfvars"

terraform apply "plan.tfplan"

terraform destroy -auto-approve -var-file="env.tfvars"

```

1. si la vm se puso loca siempre podes 
```zsh 
qm destroy <id-vm>
```

# REF
https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/
https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/
