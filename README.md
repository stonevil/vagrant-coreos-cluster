[![Build Status](https://secure.travis-ci.org/stonevil/vagrant-coreos-cluster.png?branch=master)](https://travis-ci.org/stonevil/vagrant-coreos-cluster)

# CoreOS Vagrant cluster

Just another repo with Vagrant template to create a CoreOS virtual cluster using the VirtualBox OR VMWare Fusion software hypervisor. After setup is complete you will have a single OR multiply CoreOS virtual machine's running on your host workstation.

## Setup

1) Install dependencies

* VirtualBox 4.3.10 or greater OR VMWare Fusion 6.0 or greater
* Vagrant 1.6.5 or greater.

2) Clone this project and get it running!

```
git clone https://github.com/stonevil/vagrant-coreos-cluster/
cd vagrant-coreos-cluster
```

3) Startup and SSH

```
For VirtualBox
vagrant up
```
OR

```
VMWare Fusion
vagrant up --provider vmware_fusion

vagrant ssh
```

## Cluster Setup

Launching a CoreOS cluster on Vagrant is as simple as configuring `$coreos_instances` in a `Vagrantfile` file to 3 (or more!) and running `vagrant up`.
Make sure you provide a fresh discovery URL in your `user-data` if you wish to bootstrap etcd in your cluster.

## Docker Forwarding

By setting the `$coreos_docker_port` configuration value you can forward a local TCP port to docker on each CoreOS machine that you launch. The first machine will be available on the port that you specify and each additional machine will increment the port by 1.

Then you can then use the `docker` command from your local shell by setting `DOCKER_HOST`:

    export DOCKER_HOST=tcp://localhost:4243
