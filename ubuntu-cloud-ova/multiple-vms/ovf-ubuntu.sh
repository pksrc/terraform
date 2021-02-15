#!/bin/bash -x

vmname='ubuntu-cloud-20.04'

ovftool \
--acceptAllEulas \
--name=$vmname \
--datastore=datastore2-30 \
--network=dPG-Access \
--vmFolder=Templates \
--importAsTemplate \
/Users/kandasamyp/Code/bits/linux/ubuntu/ubuntu-20.04-server-cloudimg-amd64.ova \
"vi://administrator@vsphere.local:VMware1!@VCSA_IP/LAB/host/Mgmt/esxi03.lab.vsphere.com"

