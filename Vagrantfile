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
Vagrant.require_version '>= 1.7.2'

# Define hash of supported providers and plugins
$providers = { 'azure' => 'vagrant-azure', 'aws' => 'vagrant-aws', 'digital_ocean' => 'vagrant-digitalocean', 'google' => 'vagrant-google', 'virtualbox' => 'vagrant-virtualbox', 'vmware_fusion' => 'vagrant-vmware-fusion', 'vmware_workstation' => 'vagrant-vmware-workstation' }
$providers_wave =  ['vmware_fusion', 'vmware_workstation', 'azure', 'google']

# Vagrant vagrant-hostmanager plugin must be installed for support /etc/hosts file auto-update.
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

# SSH port increment variable for Azure
$ssh_port = 9000

# You can add own script for provisioning during CoreOS cluster startup
$script = <<SCRIPT
echo CoreOS cluster ready to use
SCRIPT

# Define user-data template file
COREOS_CLOUD_USER_DATA = File.join(File.dirname(__FILE__), 'user-data.erb')

# Override default CoreOS Cluster configuration at config.rb
COREOS_CONFIG = File.join(File.dirname(__FILE__), 'config.rb')

# Override configuration from external configuration file
if File.exist?(COREOS_CONFIG)
  require COREOS_CONFIG
  puts 'Custom configuration loaded from file ' + COREOS_CONFIG
end

# Configure shared folder
if $shared_folder_name
  $coreos_cloud_shared_path = File.join(File.dirname(__FILE__), $shared_folder_name)
  puts 'Host workstation shared folder path: ' + $coreos_cloud_shared_path
end if ARGV[0] == 'up' || ARGV[0] == 'provision'

# CoreOS etcd key can be predefined with env variable COREOS_ETCD_DISCOVERY_KEY or config.rb
if [nil, 0, false].include?($coreos_etcd_key) && (ARGV[0] == 'up' || ARGV[0] == 'provision')
  if [nil, 0, false].include?(ENV['COREOS_ETCD_DISCOVERY_KEY'])
    puts 'Vagrant CoreOS etcd key generation...'
    $coreos_etcd_key = Net::HTTP.get($coreos_etcd_url)
  else
    $coreos_etcd_key = ENV['COREOS_ETCD_DISCOVERY_KEY']
  end
  puts 'CoreOS etcd key: ' + $coreos_etcd_key
end

# Add Vagrant hostmanager plugin support if required
system 'vagrant plugin install vagrant-hostmananger' if $hostmanager unless Vagrant.has_plugin?('vagrant-hostmanager')

# Install necessary plugins
system 'vagrant plugin install vagrant-berkshelf' unless Vagrant.has_plugin?('vagrant-berkshelf')
system 'vagrant plugin install vagrant-omnibus' unless Vagrant.has_plugin?('vagrant-omnibus')


# Get provider from Environment variables and command line parameters. Command line parameters haves higher priority
if !ARGV.nil? && ARGV.join('').include?('provider')
  ARGV.each do|arg|
    if arg.include?('provider')
      $provider = arg.split('=').last
    end
  end
else
  if !ENV['VAGRANT_DEFAULT_PROVIDER'].nil?
    $provider = ENV['VAGRANT_DEFAULT_PROVIDER']
  else
    $provider = 'virtualbox'
  end
end

# Install required provider plugins
$provider_plugin = $providers.fetch($provider, 'virtualbox')
system("vagrant plugin install #{$provider_plugin}") unless Vagrant.has_plugin?$provider_plugin || exit! if !$provider == 'virtualbox'


################################################################################


Vagrant.configure("2") do |config|
  # Configure version and channel
  config.vm.box = 'coreos-%s' % $coreos_channel
  config.vm.box_version = $coreos_version
  config.vm.box_url = 'http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json' % $coreos_channel
  config.vm.boot_timeout = 2000

  # Get CoreOS box
  case $provider
    when 'virtualbox'
      ["virtualbox"].each do |virtualbox|
        config.vm.provider virtualbox do |v|
          # Force VN do not install vb guest additions
          v.check_guest_additions = false
          v.functional_vboxsf = false
          # Resolve Vagrant plugin conflict
          config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')
        end
      end
    when 'vmware_fusion'
      ["vmware_fusion"].each do |vmware_fusion|
        config.vm.provider vmware_fusion do |vb, override|
          override.vm.box_url = 'http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json' % $coreos_channel
        end
      end
    when 'vmware_workstation'
      ["vmware_workstation"].each do |vmware_workstation|
        config.vm.provider vmware_workstation do |vb, override|
          override.vm.box_url = 'http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json' % $coreos_channel
        end
      end
    when 'aws'
      ["aws"].each do |aws|
        config.vm.provider aws do |x, override|
          override.vm.box = 'dummy'
          override.vm.box_url = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
          override.vm.box_version = ''
        end
      end
    when 'azure'
      ["azure"].each do |azure|
        config.vm.provider azure do |q, override|
          override.vm.box = 'azure'
          override.vm.box_url = 'https://github.com/msopentech/vagrant-azure/raw/master/dummy.box'
          override.vm.box_version = ''
        end
      end
    when 'digital_ocean'
      ["digital_ocean"].each do |digital_ocean|
        config.vm.provider digital_ocean do |z, override|
          override.vm.box = 'digital_ocean'
          override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
          override.vm.box_version = ''
        end
      end
    when 'google'
      ["google"].each do |google|
        config.vm.provider google do |z, override|
          override.vm.box = 'gce'
          override.vm.box_url = 'https://github.com/mitchellh/vagrant-google/raw/master/google.box'
          override.vm.box_version = ''
        end
      end
  end


  # Deploy CoreOS cluster
  (1..$coreos_instances).each do |i|
    config.vm.define vm_name = "core-%02d" % i do |config|
      config.vm.hostname = vm_name
      $ssh_port = ($ssh_port + 1)


      # Manage console logging
      if $serial_logging
        logdir = File.join(File.dirname(__FILE__), 'log')
        FileUtils.mkdir_p(logdir)
        serialFile = File.join(logdir, '%s-serial.txt' % vm_name)
        FileUtils.touch(serialFile)
        case $provider
          when 'virtualbox'
            vb.customize ['modifyvm', :id, '--uart1', '0x3F8', '4']
            vb.customize ['modifyvm', :id, '--uartmode1', serialFile]
          when 'vmware_fusion', 'vmware_workstation'
            v.vmx['serial0.present'] = 'TRUE'
            v.vmx['serial0.fileType'] = 'file'
            v.vmx['serial0.fileName'] = serialFile
            v.vmx['serial0.tryNoRxLoss'] = 'FALSE'
        end
      end


      # Configure network
      case $provider
        when 'virtualbox'
          ip = "172.17.8.#{i+100}"
        when 'vmware_fusion', 'vmware_workstation'
          ip = "172.17.10.#{i+100}"
      end

      config.vm.network :private_network, ip: ip, auto_config: true

      # Expose CoreOS Docker API over TCP
      config.vm.network 'forwarded_port', guest: 4243, host: $coreos_docker_port + i - 1, auto_correct: true if $coreos_docker_port
      # Expose CoreOS etcd over TCP
      config.vm.network 'forwarded_port', guest: 4001, host: $coreos_etcd_port + i - 1, auto_correct: true if $coreos_etcd_port
      # Expose CoreOS peer address over TCP
      config.vm.network 'forwarded_port', guest: 7001, host: $coreos_peer_port + i - 1, auto_correct: true if $coreos_peer_port


      # Manage GUI
      case $provider
        when 'virtualbox'
         config.vm.provider :virtualbox do |vb|
           vb.gui = $vb_gui
         end
        when 'vmware_fusion', 'vmware_workstation'
         config.vm.provider :vmware_fusion do |vb|
           vb.gui = $vb_gui
         end
      end

      # CoreOS cloud config
      if File.exist?(COREOS_CLOUD_USER_DATA)
        # Generate config file for CoreOS
        puts 'Vagrant CoreOS user-data config file generation...'
        user_data_template = ERB.new File.new(COREOS_CLOUD_USER_DATA).read, nil, '%'
        user_data_output = user_data_template.result(binding)
      end if ARGV[0] == 'up' || ARGV[0] == 'provision'


      case $provider
        when 'azure'
          # Microsoft Azure
          ["azure"].each do |azure|
            config.vm.provider azure do |a, override|
              a.mgmt_certificate = ENV['AZURE_MGMT_CERT']
              a.mgmt_endpoint = ENV['AZURE_MGMT_ENDPOINT']
              a.subscription_id = ENV['AZURE_SUB_ID']
              a.storage_acct_name = ENV['AZURE_STORAGE_ACCT']
              a.vm_image = ENV['AZURE_VM_IMAGE']
              a.vm_user = 'core'
              a.vm_password = ''
              a.vm_name = config.vm.hostname
              a.cloud_service_name = 'coreoscloud'
              a.deployment_name = config.vm.hostname
              a.vm_location = 'West US'
              override.ssh.username = 'core'
              override.ssh.private_key_path = ENV['AZURE_SSH_PRIV_KEY']
              a.private_key_file = ENV['AZURE_PRIV_KEY']
              a.certificate_file = ENV['AZURE_CERT_FILE']
              a.ssh_port = $ssh_port
            end
          end
        when 'digital_ocean'
          # Digital Ocean
          ["digital_ocean"].each do |digital_ocean|
            config.vm.provider digital_ocean do |d, override|
              d.token = ENV['DIGITALOCEAN_TOKEN']
              d.image = ENV['DIGITALOCEAN_IMAGE']
              d.region = ENV['DIGITALOCEAN_REGION']
              d.size = ENV['DIGITALOCEAN_SIZE']
              d.root_username = 'core'
              d.private_networking = true
              override.ssh.username = 'core'
              override.ssh.private_key_path = ENV['DIGITALOCEAN_SSH_KEY']
              d.user_data = user_data_output
              d.setup = false
            end
          end
        when 'google'
          # Google Cloud Platform
          ["google"].each do |google|
            config.vm.provider google do |g, override|
              g.google_project_id = ENV['GOOGLECLOUD_PROJECT']
              g.google_client_email = ENV['GOOGLECLOUD_CLIENT_EMAIL']
              g.google_key_location = ENV['GOOGLECLOUD_KEY_LOCATION']
              g.machine_type = ENV['GOOGLECLOUD_MACHINETYPE']
              g.image = ENV['GOOGLECLOUD_IMAGE']
              g.name = vm_name
              g.metadata = { 'user-data' => user_data_output }
              override.ssh.private_key_path = ENV['GOOGLECLOUD_OVERRIDE_KEY']
              override.ssh.username = 'core'
            end
          end
        when 'aws'
          # AWS
          ["aws"].each do |aws|
            config.vm.provider aws do |a, override|
              a.access_key_id = ENV['AWS_ACCESS_KEY']
              a.secret_access_key = ENV['AWS_SECRET_KEY']
              a.keypair_name = ENV['AWS_KEY_FILE']
              a.region = ENV['AWS_REGION']
              a.instance_type = ENV['AWS_INSTANCE']
              a.security_groups = ENV['AWS_SECURITYGROUP']
              a.ami = ENV['AWS_AMI']
              a.user_data = user_data_output
              override.ssh.private_key_path = ENV['AWS_KEYPATH']
              override.ssh.username = 'core'
            end
          end
      end


      # Share folder over NFS with CoreOS
      case $provider
        when 'virtualbox', 'vmware_fusion', 'vmware_workstation'
          config.vm.synced_folder $coreos_cloud_shared_path, '/' + $shared_folder_name, id: 'core', nfs: true, mount_options: ['nolock,vers=3,udp']
      end if File.exist?($coreos_cloud_shared_path) if $shared_folder_name if ARGV[0] == 'up' || ARGV[0] == 'provision'

      # Deploy user-data config file
      case $provider
        when 'azure'
          config.vm.provision 'shell', inline: 'mkdir -p /var/lib/coreos-install/', :privileged => true
          config.vm.provision 'shell', inline: "echo '#{user_data_output}' > /tmp/vagrantfile-user-data", privileged: true
          config.vm.provision 'shell', inline: 'mv /tmp/vagrantfile-user-data /var/lib/coreos-install/user_data', privileged: true
        when 'aws', 'google', 'digital_ocean', 'vmware_fusion', 'vmware_workstation'
          config.vm.provision 'shell', inline: "echo '#{user_data_output}' > /tmp/vagrantfile-user-data", privileged: true
          config.vm.provision 'shell', inline: 'mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/', privileged: true
      end
      # Execute custome script
      config.vm.provision 'shell', inline: $script, privileged: true

    end
  end
end
