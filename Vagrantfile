# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile for ansible-multitier-deploy — a 3-VM lab running a multi-tier
# stack (Nginx → Tomcat → MySQL) managed by Ansible.
#
# Designed for Apple Silicon (M1/M2/M3/M4) using VMware Fusion.
# All VMs use bento/ubuntu-22.04 (ARM64 Ubuntu 22.04).
#
# Use --no-parallel to bring VMs up in dependency order:
#   vagrant up --no-parallel

VMS = {
  "db01"  => { ip: "192.168.56.33", memory: 768,  box: "bento/ubuntu-22.04" },
  "app01" => { ip: "192.168.56.32", memory: 1024, box: "bento/ubuntu-22.04" },
  "web01" => { ip: "192.168.56.31", memory: 1024, box: "bento/ubuntu-22.04" },
}

Vagrant.configure("2") do |config|
  # vagrant-hostmanager plugin maintains /etc/hosts on guests and the host
  # so the VMs can resolve each other by hostname.
  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled           = true
    config.hostmanager.manage_host       = true
    config.hostmanager.manage_guest      = true
    config.hostmanager.ignore_private_ip = false
  end

  config.vm.boot_timeout = 900

  VMS.each do |name, cfg|
    config.vm.define name do |node|
      node.vm.box      = cfg[:box]
      node.vm.hostname = name
      node.vm.network "private_network", ip: cfg[:ip]

      node.vm.provider "vmware_desktop" do |vmware|
        vmware.gui                = false
        vmware.allowlist_verified = true
        vmware.memory             = cfg[:memory]
        vmware.cpus               = 1
      end
    end
  end
end

