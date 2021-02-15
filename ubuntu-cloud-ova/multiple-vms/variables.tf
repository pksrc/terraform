# General vCenter data
# vCenter / ESXi Username
variable "user" {
    description = "vSphere Admin User"
}

# vCenter / ESXi Password
variable "password" {
    description = "vSphere Admin Password"
}

# vCenter / ESXi Endpoint
variable "vsphere_server" {
    description = "vSphere/ESXi endpoint IP or fqdn"
}

# vCenter / ESXi Datacenter
variable "datacenter" {
    description = "vSphere/ESXi datacenter"
}

# vCenter / ESXi Datastore
variable "datastore" {
    description = "vSphere/ESXi datastore"
}

# vCenter / ESXi ResourcePool
variable "resource_pool" {
    description = "vSphere/ESXi Resources - when it doubt use govc to get the info"
}

# Virtual Template and common
# Name of OVA template (chosen in import process)
variable "template" {
    description = "name of the template that will be cloned"
}

# VM Network 
variable "network" {
    description =  "network for the VM to reside in"
}

# Control Plane Node configuration
variable "namem" {
    description = "name of the VM to be spun up"
}

# VM Number of CPU's
variable "cpum" {
    description = "# VM Number of CPU's"
}

# VM Memory in MB
variable "memorym" {
    description = "# VM Memory in MB"
}

# Capacity Node configuration
variable "namew" {
    description = "name of the VM to be spun up"
}

# VM Number of CPU's
variable "cpuw" {
    description = "# VM Number of CPU's"
}

# VM Memory in MB
variable "memoryw" {
    description = "# VM Memory in MB"
}