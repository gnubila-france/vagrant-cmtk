# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos-65-x64-virtualbox-nocm"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-nocm.box"

  # vagrant-cachier - cache at the box level
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Shell provisionner for bootstrapping package building configuration
  config.vm.provision "shell", path: "package-building.sh"

  # Setup the Puppet master
  config.vm.define :build, primary: true do |node|
    # Configure memory
    node.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", 2]
    end
    # Set hostname
    node.vm.hostname = "buildcmtk.local.lan"
    # Set ip address
    node.vm.network "private_network", type: "dhcp"
  end
end
