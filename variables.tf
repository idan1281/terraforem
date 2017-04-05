# Variables section
variable "region" { default = "eu-de-1" } #Other region `au-ap-1`
variable "image" { default = "sles-12-sp1-amd64-vmware-build98" }
variable "guest_os" { default = "linux" }
variable "key_pair" { default = "Idan-Pub2" }
variable "db_flavor" { default = "90" }
variable "app_flavor" { default = "40" }
variable "security_group" { default = "default" }
# variable "web_ip" { default = "10.47.1.63" } # Provide the floating ip you have created already via dashboard. Comment this line if you are creating one using terraform.
# variable "web_dns" { default = "web.consulting.c.eu-de-1.cloud.sap" } # You can pass this to script to automation scripts.
variable "ssh_user_name" { default = "ccloud" }
variable "ssh_key_path" { default = "/Users/c5240533/.ssh/id_rsa" } # On macOS, it is `/Users/<your_user_name>/.ssh/id_rsa`; on Windows `C:\Users\<your_user_name>\.ssh\id_rsa`
variable "db_tag" { default = "s4h-db" }
variable "app_tag" { default = "s4h-app"}
variable "dns_enabled" { default = "false"}
variable "hana_revision" { default = "82"}
variable "s4h_version" { default = "1506"} #in app json it is referenced as SAPERP_VERSION