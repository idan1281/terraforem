# Variables section
#variable "region" { default = "eu-de-1" } #Other region `au-ap-1`
#variable "image" { default = "sles-12-sp1-amd64-vmware-build98" }
#variable "guest_os" { default = "linux" }
#variable "key_pair" { default = "Idan-Pub2" }
#variable "flavor" { default = "20" }
#variable "security_group" { default = "default" }
# variable "web_ip" { default = "10.47.1.63" } # Provide the floating ip you have created already via dashboard. Comment this line if you are creating one using terraform.
# variable "web_dns" { default = "web.consulting.c.eu-de-1.cloud.sap" } # You can pass this to script to automation scripts.
#variable "ssh_user_name" { default = "ccloud" }
#variable "ssh_key_path" { default = "/Users/c5240533/.ssh/id_rsa" } # On macOS, it is `/Users/<your_user_name>/.ssh/id_rsa`; on Windows `C:\Users\<your_user_name>\.ssh\id_rsa`

# Provider section
#provider "openstack" {
#}

#create Disk for DB
resource "openstack_blockstorage_volume_v2" "vol_db" {
 region = "${var.region}"
 name = "vol_db"
 description = "Volume for DB server"
 size = 301 # in Giga Byte
}


# create an FIP for DB
resource "openstack_networking_floatingip_v2" "db_ip"
{
        pool = "FloatingIP-internal-monsoon3"
}

## installing DB server
resource "openstack_compute_instance_v2" "db_instance"
{
  name = "Idan-s4h-db"
  region = "${var.region}"
  image_name = "${var.image}"
  flavor_id = "${var.db_flavor}"
  key_pair = "${var.key_pair}"
  security_groups = ["default"]

  # Attach the Volume
  volume {
    device = "/dev/sdc"
    volume_id = "${openstack_blockstorage_volume_v2.vol_db.id}"
}

  # Connection details
  connection
  {
    user = "${ var.ssh_user_name }"
    private_key = "${file("${var.ssh_key_path}")}"
    agent = false
  }

  # Create an internal ip and attach floating ip to it
  network
  {
    uuid = "431361d3-e329-4f1b-9135-2819a3e9c6cd"
    name = "Private-corp-sap-shared-01"
    floating_ip = "${openstack_networking_floatingip_v2.db_ip.address}"
    access_network = true
    # Whether to use this network to access the instance or provision
  }
}

  #Post Install Script after instance creation
  resource "null_resource" "db" {
    triggers {
      db_instance_id = "${ openstack_compute_instance_v2.db_instance.id }"
    }

    # Connection details to do provision
    connection {
      host = "${ openstack_networking_floatingip_v2.db_ip.address  }"
      user = "${ var.ssh_user_name }"
      private_key = "${file("${var.ssh_key_path}")}"
      agent = false
    }

    # Calling lyra_install script which takes care of lyra client installation locally.
    provisioner "local-exec" "call_lyra_script" {
      command = "scripts/lyra_install.sh ${openstack_compute_instance_v2.db_instance.id} ${ var.guest_os }"
    }

    # Script to run on target instance to clean up previous arc installation, useful for subsequent provisions.
    provisioner "remote-exec" {
      inline = [
        "sudo systemctl stop arc.service",
        "sudo rm -rf /opt/arc"
      ]
    }

    # Copy the three lines arc install script to target instance and run it from there
    provisioner "remote-exec" {
      script = "tmp/INS_${openstack_compute_instance_v2.db_instance.id}.sh"
    }

    # Execute and watch create_file_2 automation
    provisioner "local-exec" "call_automation_script" {
      command = "scripts/automation_create_db.sh ${openstack_compute_instance_v2.db_instance.id}"
    }
  }



  ####################

