# To automatically replace the discovery token on 'vagrant up', uncomment
# the lines below:
#
#if File.exists?('user-data') && ARGV[0].eql?('up')
#  require 'open-uri'
#  require 'yaml'
#
#  token = open('https://discovery.etcd.io/new').read
#
#  data = YAML.load(IO.readlines('user-data')[1..-1].join)
#  data['coreos']['etcd']['discovery'] = token
#
#  yaml = YAML.dump(data)
#  File.open('user-data', 'w') { |file| file.write("#cloud-config\n\n#{yaml}") }
#end

$coreos_channel = "coreos-alpha"
$coreos_version = ">=417.1.0"

# Size of the CoreOS cluster created by Vagrant
$num_instances = 1

# Log the serial consoles of CoreOS VMs to log/
# Enable by setting value to true, disable with false
# WARNING: Serial logging is known to result in extremely high CPU usage with
# VirtualBox, so should only be used in debugging situations
$coreos_enable_serial_logging = false

$coreos_memeory = 2024
$coreos_cpu = 1
$shared_folder_path = "share"

# Enable port forwarding of Docker TCP socket
# Set to the TCP port you want exposed on the *host* machine, default is 4243
# If 4243 is used, Vagrant will auto-increment (e.g. in the case of $num_instances > 1)
# You can then use the docker tool locally by setting the folloing env var:
#   export DOCKER_HOST='tcp://127.0.0.1:4243'
$coreos_expose_docker_tcp=4243
