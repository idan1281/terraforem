# Provider section
provider "openstack" {
}

data "openstack_networking_network_v2" "network" {
 name = "${var.private_network}"
}

#create Disk for DB
resource "openstack_blockstorage_volume_v2" "vol_db" {
 region = "${var.region}"
 name = "vol_db"
 description = "Volume for DB server"
 size = 3 # in Giga Byte
# availability_zone = "${var.availability_zone}"
}

# create an FIP for DB
resource "openstack_networking_floatingip_v2" "db_ip"
{
        pool = "FloatingIP-external-monsoon3-03"
}

## installing DB server
resource "openstack_compute_instance_v2" "db_instance"
{
  name = "demo-s4h-db"
  region = "${var.region}"
  image_name = "${var.image}"
  flavor_id = "${var.db_flavor}"
  key_pair = "${var.key_pair}"
  security_groups = ["default"]
 # availability_zone = "${var.availability_zone}"

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
    uuid = "${data.openstack_networking_network_v2.network.id}" 
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

    # run a script to read the server name from the file created in previous step and generate attribute file in json format
    provisioner  "local-exec" "create_db_json_script" {
      command = "scripts/create_db_json_script.sh ${ var.db_tag } ${ var.app_tag } ${ var.hana_revision } ${ var.s4h_version }"
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
      command = "scripts/automation_create_db.sh ${openstack_compute_instance_v2.db_instance.id} ${ var.db_tag }"
    }
  }

#########  APP creation #########

#Create Disk for App
resource "openstack_blockstorage_volume_v2" "vol_app" {
 region = "${var.region}"
 name = "vol_app"
 description = "Volume for App server"
 size = 1 # in Giga Byte
}
#creating an FIP for app
resource "openstack_networking_floatingip_v2" "app_ip"
{
        pool = "FloatingIP-external-monsoon3-03"
}

resource "openstack_compute_instance_v2" "app_instance"
{
  name = "demo-s4h-app"
  region = "${var.region}"
  image_name = "${var.image}"
  flavor_id = "${var.app_flavor}"
  key_pair = "${var.key_pair}"
  security_groups = ["default"]
  depends_on = ["null_resource.db"]

  # Attach the Volume
  volume {
    device = "/dev/sdc"
    volume_id = "${openstack_blockstorage_volume_v2.vol_app.id}"
}
  # Connection details
  connection
  {
      user = "${ var.ssh_user_name }"
      private_key = "${file("${var.ssh_key_path}")}"
      agent = false
  }

  #nova meta-data
  metadata
  {
    color = "red"
    category = "hana"
  }

  # Create an internal ip and attach floating ip to it
  network
  {
    uuid = "${data.openstack_networking_network_v2.network.id}"
    floating_ip = "${openstack_networking_floatingip_v2.app_ip.address}"
    access_network = true # Whether to use this network to access the instance or provision
  }

  #cloud-init Configuration
  user_data = "${file("cloud_config/cloud_config_rhel7.yml")}"
}

#Post Install Script after instance creation
resource "null_resource" "app" {
  triggers {
    web_instance_id = "${ openstack_compute_instance_v2.app_instance.id }"
  }

  # Connection details to do provision
  connection {
    host = "${ openstack_networking_floatingip_v2.app_ip.address  }"
    user     = "${ var.ssh_user_name }"
        private_key = "${file("${var.ssh_key_path}")}"
    agent = false
  }

  # Calling lyra_install script which takes care of lyra client installation locally.
    provisioner "local-exec" "call_lyra_script" {
      command = "scripts/lyra_install.sh ${openstack_compute_instance_v2.app_instance.id} ${ var.guest_os }"
    }

    # run a script to generate attribute file in json format for the hostfix automation
    provisioner "local-exec" "create_hostfix_json_script" {
      command = "scripts/create_hostfix_json_script.sh ${ var.db_tag } ${var.app_tag} ${var.dns_enabled}"
    }


  # run a script to generate attribute file in json format for the app automation
  provisioner  "local-exec" "create_app_json_script" {
     command = "scripts/create_app_json_script.sh ${ var.db_tag } ${ var.app_tag } ${ var.s4h_version }"
    }


 # Script to run on target instance to clean up previous arc installation, useful for subsequent provisions.
  provisioner  "remote-exec" {
    inline = [
      "sudo systemctl stop arc.service",
      "sudo rm -rf /opt/arc"
      ]
  }

  # Copy the three lines arc install script to target instance and run it from there
  provisioner "remote-exec" {
    script = "tmp/INS_${openstack_compute_instance_v2.app_instance.id}.sh"
  }

  # Execute and watch create the HOSTFIX automation
  provisioner  "local-exec" "call_automation_script" {
    command = "scripts/automation_create_hostfix.sh ${openstack_compute_instance_v2.app_instance.id} ${ var.app_tag } ${var.dns_enabled}"
  }

  # Execute and watch create the APP automation
  provisioner  "local-exec" "call_automation_script" {
    command = "scripts/automation_create_app.sh ${openstack_compute_instance_v2.app_instance.id} ${ var.app_tag }"
  }
}

output "web_metadata_category"
{
  value = "${openstack_compute_instance_v2.app_instance.metadata.catagory}"
}

# Use `terraform output web_instance_id` to retrieve the value
output "app_instance_id"
{
  value = "${openstack_compute_instance_v2.app_instance.id}"
}

# Use `terraform output DB_instance_name` to retrieve the value
output "db_instance_name"
{
  value = "${openstack_compute_instance_v2.db_instance.name}"
}

# Use `terraform output web_instance_id` to retrieve the value
output "db_instance_id"
{
  value = "${openstack_compute_instance_v2.db_instance.id}"
}

# Use `terraform output APP_instance_name` to retrieve the value
output "app_instance_name"
{
  value = "${openstack_compute_instance_v2.app_instance.name}"
}
