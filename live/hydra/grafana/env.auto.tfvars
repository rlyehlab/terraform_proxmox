vm_name       = "Grafana"
memory        = 2048
vm_id          = 114
network_bridge = "vmbr1"
ipv4_address   = "10.13.10.104/24"
ipv4_gateway   = "10.13.10.1"
cores         = 2
disk_size     = 8
template_name = "ubuntu"
tags          = ["terraform", "ubuntu", "production"]
vm_user       = "user"
agent_enabled = false
ssh_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDcNcHVpSVDCUpyfX8u3IU79tq3YC/+t8ROBb/4FKKG vlad@rlab.com",
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8z+XOiIZhrCbeMO6pJjQtU29YAheChLkUeVnZueMH8 odradek@rlab.be",
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCGeLU9MtiXkJkNIP1ZEU/bbnPD3yB80w0yA4PxEvdih8nqWLHO/4jO4wSi3gDN/AwDAPry6AeY401bgdnP0y8pG63xMQyx/qS2yp4089mUJ37jorG8CEge1WObk2e3Sm0dux+c2SI3vKNN1y3sq1vhmFg4QkvgnIfb9p9KX1lvGjhfT1piR7OORaHR15GVcS1Yu5a1d6UzPr+5E1j/oT+amloeInjlLqneRK1PwDz46oSj90QAnv8pXuu5YvzYlKp+B3Dk0j+CWQ6cSY0T0PgTvBdRGXMzjZNfQZQX67a1Ave7hYC2PWB9UqmFMUvfh5XZMs21CzfHIWDoys/f1KH1/JykL/Q/5aYh9OhNATtdLs79O96ZLu1A0Ltlt6vaDfy+1T2FtCLQVmIqsczdvFZKi6aD+jgTTEZ/KrSNykm93VvwfCBQZyASYtM3HNPwRZPWtSj2KfA8XlixxGyBnyjb5KHwAm3YaXzId1m5kzNBdQ8kcWBHgMpLAref9KcBawjXzV2Yh4BdHceWe/e8+083oFnolfIWvLXyxtPNb3qUf0Ri8rMJN2nwOjcQ/SFQTme8CEDllvisZWGY0BIjO7HTXXXa+nAlMCgk1a/16duds1yTXEZ+olCB5zM2fsuu5tY7bLUR0YbqjEzkW1jm5/f0beEP2cvWLkzdrgeNSYT5lw== caripa.front@gmail.com",
]
