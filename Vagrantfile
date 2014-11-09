# -*- mode: ruby -*-
# # vi: set ft=ruby :


# PLEASE DO NOT CHANGE ANYTHING IN THIS FILE!
# FOR CHANGES PLEASE CREATE COPY OF THE config.rb.example
# AND PROVIDE ALL CHANGES TO config.rb


# Define required ruby libs
require 'net/http'
require 'fileutils'
require 'erb'

# Define Vagrant minimal version
Vagrant.require_version '>= 1.6.5'

# Vagrant vagrant-hostmanager plugin must be installed for support hosts auto-update.
# Required plugin will be installed automatically.
# Read more at https://github.com/smdahlen/vagrant-hostmanager
$hostmanager = false

# Default CoreOS Cluster configuration.
$coreos_channel = 'alpha'
$coreos_version = '>=493.0.0'

$coreos_instances = 1

$shared_folder_name = false

$coreos_docker_port = 4243
$coreos_peer_port = 7001
$coreos_etcd_port = 4001

$coreos_etcd_url = URI('https://discovery.etcd.io/new')
$coreos_etcd_key = false

# Enable only for debuging purpose. This functionality highly slow down you computer!
$serial_logging = false


# You can add own options for Docker containers provisioning during CoreOS cluster startup
$docker = <<DOCKER
images: ["ubuntu"]
DOCKER

# You can add own script for provisioning during CoreOS cluster startup
$script = <<SCRIPT
echo CoreOS cluster ready to use
SCRIPT

# Define user-data template file
COREOS_CLOUD_USER_DATA = File.join(File.dirname(__FILE__), 'user-data.erb')

# Override default CoreOS Cluster configuration at config.rb
COREOS_CONFIG = File.join(File.dirname(__FILE__), 'config.rb')

# Override configuration from external configuration file
require COREOS_CONFIG if File.exist?(COREOS_CONFIG)


# Add Vagrant hostmanager plugin support if required
system 'vagrant plugin install vagrant-hostmananger' if $hostmanager unless Vagrant.has_plugin?('vagrant-hostmanager')
# Add VMWare Fusion support if required
system 'vagrant plugin install vmware_fusion' if ENV['VAGRANT_DEFAULT_PROVIDER'] == 'vmware_fusion' unless Vagrant.has_plugin?('vmware_fusion')


# Configure shared folder
COREOS_CLOUD_SHARED_PATH = File.realpath($shared_folder_name) until [nil, 0, false].include?($shared_folder_name)

# CoreOS etcd key can be predefined with env variable COREOS_ETCD_DISCOVERY_KEY or config.rb
if [nil, 0, false].include?($coreos_etcd_key) && (ARGV[0] == 'up' || ARGV[0] == 'provision')
  if [nil, 0, false].include?(ENV['COREOS_ETCD_DISCOVERY_KEY'])
    puts 'Vagrant CoreOS etcd key generation...'
    $coreos_etcd_key = Net::HTTP.get($coreos_etcd_url)
  else
    $coreos_etcd_key = ENV['COREOS_ETCD_DISCOVERY_KEY']
  end
end


################################################################################
Vagrant.configure('2') do |config|
  config.vm.box = 'coreos-%s' % $coreos_channel
  config.vm.box_version = $coreos_version

  # Get CoreOS box
  config.vm.provider :virtualbox do |v|
    config.vm.box_url = 'http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json' % $coreos_channel
    # Force VN do not install vb guest additions
    v.check_guest_additions = false
    v.functional_vboxsf = false
  end
  config.vm.provider :vmware_fusion do
    config.vm.box_url = 'http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json' % $coreos_channel
  end

  # Resolve Vagrant plugin conflict
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')

  # Deploy CoreOS cluster
  (1..$coreos_instances).each do |i|
    config.vm.define vm_name = 'core-%02d' % i do |config|
      config.vm.hostname = vm_name

      # Expose CoreOS Docker API over TCP
      if $coreos_docker_port
        config.vm.network 'forwarded_port', guest: 4243, host: $coreos_docker_port + i - 1, auto_correct: true
      end
      # Expose CoreOS etcd over TCP
      if $coreos_etcd_port
        config.vm.network 'forwarded_port', guest: 4001, host: $coreos_etcd_port + i - 1, auto_correct: true
      end

      # Expose CoreOS peer address over TCP
      if $coreos_etcd_port
        config.vm.network 'forwarded_port', guest: 7001, host: $coreos_peer_port + i - 1, auto_correct: true
      end

      # Manage console logging
      if $serial_logging
        logdir = File.join(File.dirname(__FILE__), 'log')
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, '%s-serial.txt' % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb|
          vb.customize ['modifyvm', :id, '--uart1', '0x3F8', '4']
          vb.customize ['modifyvm', :id, '--uartmode1', serialFile]
        end
        config.vm.provider :vmware_fusion do |v|
          v.vmx['serial0.present'] = 'TRUE'
          v.vmx['serial0.fileType'] = 'file'
          v.vmx['serial0.fileName'] = serialFile
          v.vmx['serial0.tryNoRxLoss'] = 'FALSE'
        end
      end

      # Manage host machine and vm hosts records
      if $hostmanager
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = true
        config.hostmanager.ignore_private_ip = false
        config.hostmanager.include_offline = true
      end

      # Share folder over NFS with CoreOS
      until [nil, 0, false].include?($shared_folder_name)
        if File.exist?(COREOS_CLOUD_SHARED_PATH)
          config.vm.synced_folder '#{COREOS_CLOUD_SHARED_PATH}', '/' + $shared_folder_name, id: 'core', nfs: true, mount_options: ['nolock,vers=3,udp']
        end
      end

      # CoreOS cloud config
      if ARGV[0] == 'up' || ARGV[0] == 'provision'
        if File.exist?(COREOS_CLOUD_USER_DATA)
          # Generate config file for CoreOS
          puts 'Vagrant CoreOS user-data config file generation...'
          user_data_template = ERB.new File.new(COREOS_CLOUD_USER_DATA).read, nil, '%'
          user_data_output = user_data_template.result(binding)
        end
      end

      # Deploy user-data config file
      config.vm.provision 'shell', inline: "echo '#{user_data_output}' > /var/lib/coreos-vagrant/vagrantfile-user-data", privileged: true
      # Docker provisioning
      config.vm.provision 'docker' do |d|
        $docker
      end
      # Execute custome script
      config.vm.provision 'shell', inline: $script, privileged: true

    end
  end
end
