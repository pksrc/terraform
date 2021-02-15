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

resource "vsphere_virtual_machine" "controller" {
  name              = var.namem
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id

  num_cpus          = var.cpum
  memory            = var.memorym
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
      user-data = base64encode(file("./cloudinit/userdata-controller.yml"))
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
      "mkdir -p $HOME/.kube",
      "while [ ! -f /etc/kubernetes/admin.conf ]; do sleep 2; done; sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    ]
    connection {
      type = "ssh"
      user = "pk"
      host = self.default_ip_address
    }
  }
}

output "controller-ip" {
  value = vsphere_virtual_machine.controller.default_ip_address
}


resource "vsphere_virtual_machine" "worker-0" {
  depends_on        = [ vsphere_virtual_machine.controller ]
  
  name              = "${var.namew}-0"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id

  num_cpus          = var.cpuw
  memory            = var.memoryw
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
      user-data = base64encode(file("./cloudinit/userdata-worker-0.yml"))
    }
  }
 
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  provisioner "remote-exec" {
    when   = create
    inline = [
      "id",
      "uname -a",
      "cat /etc/os-release",
      "echo \"machine-id is $(cat /etc/machine-id)\"",
      "df -h",
      "while [ ! -d /run/pknetes ]; do sleep 2; done; sudo chown $(id -u):$(id -g) /run/pknetes/",
      "while [ ! -f /run/pknetes/join-config.yaml ]; do sleep 2; done; sed -i 's/kube-apiserver/${vsphere_virtual_machine.controller.default_ip_address}/g' /run/pknetes/join-config.yaml",
      "sudo kubeadm join --config /run/pknetes/join-config.yaml"
    ]
    connection {
      type = "ssh"
      user = "pk"
      host = self.default_ip_address
    }
  }
}

output "worker-0-ip" {
  value = vsphere_virtual_machine.worker-0.default_ip_address
}


resource "vsphere_virtual_machine" "worker-1" {
  depends_on        = [ vsphere_virtual_machine.controller ]
  
  name              = "${var.namew}-1"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id

  num_cpus          = var.cpuw
  memory            = var.memoryw
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
      user-data = base64encode(file("./cloudinit/userdata-worker-1.yml"))
    }
  }
 
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  provisioner "remote-exec" {
    when   = create
    inline = [
      "id",
      "uname -a",
      "cat /etc/os-release",
      "echo \"machine-id is $(cat /etc/machine-id)\"",
      "df -h",
      "while [ ! -d /run/pknetes ]; do sleep 2; done; sudo chown $(id -u):$(id -g) /run/pknetes/",
      "while [ ! -f /run/pknetes/join-config.yaml ]; do sleep 2; done; sed -i 's/kube-apiserver/${vsphere_virtual_machine.controller.default_ip_address}/g' /run/pknetes/join-config.yaml",
      "sudo kubeadm join --config /run/pknetes/join-config.yaml"
    ]
    connection {
      type = "ssh"
      user = "pk"
      host = self.default_ip_address
    }
  }
}

output "worker-1-ip" {
  value = vsphere_virtual_machine.worker-1.default_ip_address
}
