# Variables section

# Region Selection
variable "region" { default = "eu-de-1" } 
#variable "region" { default = "ap-au-1" } 

variable "private_network" { default = "consulting_dev_private" }
#variable "image" { default = "sles-12-sp2-amd64-vmware-build4" }
variable "image" {}
variable "guest_os" { default = "linux" }
variable "key_pair" { default = "Idan-Pub2" }
#variable "key_pair" { default = "ap-idan" }
variable "db_flavor" { default = "90" }
variable "app_flavor" { default = "40" }
variable "security_group" { default = "default" }
variable "ssh_user_name" { default = "ccloud" }
variable "ssh_key_path" { default = "/Users/c5240533/.ssh/id_rsa" } # On macOS, it is `/Users/<your_user_name>/.ssh/id_rsa`; on Windows `C:\Users\<your_user_name>\.ssh\id_rsa`
variable "db_tag" { default = "s4h-db" }
variable "app_tag" { default = "s4h-app"}
variable "dns_enabled" { default = "false"}
variable "hana_revision" { default = "82"}
variable "s4h_version" { default = "1506"} #in app json it is referenced as SAPERP_VERSION

#Availbility zone selection
variable "availability_zone" {default = "eu-de-1b"}
#variable "availability_zone" {default = "ap-au-1b"}

