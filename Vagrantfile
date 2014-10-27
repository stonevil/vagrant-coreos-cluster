# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.5"

$coreos_channel = "alpha"
$coreos_version = ">=417.1.0"

$coreos_instances = 1

$shared_folder_name = "shared"
$coreos_docker_port=4243

COREOS_CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "user-data")
COREOS_CLOUD_SHARED_PATH = File.join(File.dirname(__FILE__), $shared_folder_name )


Vagrant.configure("2") do |config|
  config.vm.box = "coreos-%s" % $coreos_channel
  config.vm.box_version = $coreos_version

  # Get CoreOS box
  config.vm.provider :virtualbox do |v|
    config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $coreos_channel
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end
  config.vm.provider :vmware_fusion do |v|
    config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json" % $coreos_channel
  end

  # Resolve plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  # Deploy CoreOS cluster
  (1..$coreos_instances).each do |i|
    config.vm.define vm_name = "core-%02d" % i do |config|
      config.vm.hostname = vm_name

      # Expose CoreOS Docker API over TCP
      if $coreos_docker_port
        port = "#{$coreos_docker_port + i - 1}"
        config.vm.network "forwarded_port", guest: 4243, host: port, auto_correct: true
      end

      # Configure CoreOS cluster network
      ip = "172.17.8.#{i + 100}"
      config.vm.network :private_network, ip: ip

      # Share folder over NFS
      if File.exist?(COREOS_CLOUD_SHARED_PATH)
        config.vm.synced_folder "#{COREOS_CLOUD_SHARED_PATH}", "/" + $shared_folder_name, id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']
      end

      # CoreOS cloud config
      if File.exist?(COREOS_CLOUD_CONFIG_PATH)
        config.vm.provision :file, :source => "#{COREOS_CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
        config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
      end

    end
  end
end
