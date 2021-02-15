provider "vsphere" {
  user           = var.user
  password       = var.password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name          = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name              = var.name
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id

  num_cpus          = 2
  memory            = 1024
  guest_id          = data.vsphere_virtual_machine.template.guest_id

  scsi_type         = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id      = data.vsphere_network.network.id
    adapter_type    = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      user-data = base64encode(file("./cloudinit/userdata.yml"))
    }
  }
 
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  provisioner "remote-exec" {
    inline = [
      "id",
      "uname -a",
      "cat /etc/os-release",
      "echo \"machine-id is $(cat /etc/machine-id)\"",
      "df -h",
    ]
    connection {
      type = "ssh"
      user = "pk"
      host = self.default_ip_address
    }
  }
}

output "ip" {
  value = vsphere_virtual_machine.vm.default_ip_address
}
