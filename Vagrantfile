# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/debian11"
  # config.vm.box = "debian/stretch64"
  #config.vm.box = "generic/arch"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  config.vm.provision "file", source: "run_jupyter.sh", destination: "run_jupyter.sh"
  config.vm.provision "file", source: "jupyter_notebook_config.py", destination: ".jupyter/jupyter_notebook_config.py"
  config.vm.provision "file", source: "Makefile", destination: "Makefile"
  config.vm.provision "file", source: "pyenv.tail", destination: "pyenv.tail"
  config.vm.provision "shell",
   inline: "DEBIAN_FRONTEND=noninteractive apt-get install make; DEBIAN_FRONTEND=noninteractive make"

  config.vm.provider "virtualbox" do |vb|

    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbxhci", "on"]
    #manually turn off USB1, otherwise still enabled
    vb.customize ["modifyvm", :id, "--usbohci", "off"]
    vb.gui = true
    vb.name = "ChipWhisperer Jupyter"
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    vb.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'NewAE Technology Inc. ChipWhisperer Lite [0100]', '--vendorid', '0x2b3e', '--productid', '0xace2']
    vb.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'ATSAM Booloader', '--vendorid', '03EB', '--productid', '6124']
    vb.customize ['usbfilter', 'add', '1', '--target', :id, '--name', 'NewAE Technology Inc. ChipWhisperer Nano [0100]', '--vendorid', '0x2b3e', '--productid', '0xace0']
    vb.customize ['usbfilter', 'add', '2', '--target', :id, '--name', 'NewAE Technology Inc. ChipWhisperer Pro [0100]', '--vendorid', '0x2b3e', '--productid', '0xace3']
    vb.customize ['usbfilter', 'add', '2', '--target', :id, '--name', 'NewAE Technology Inc. ChipWhisperer CW305', '--vendorid', '0x2b3e', '--productid', '0xc305']
    vb.customize ['usbfilter', 'add', '2', '--target', :id, '--name', 'NewAE Technology Inc. Ballistic Gel', '--vendorid', '0x2b3e', '--productid', '0xc521']
    vb.customize ['usbfilter', 'add', '2', '--target', :id, '--name', 'NewAE Technology Inc. PhyWhisperer', '--vendorid', '0x2b3e', '--productid', '0xC610']
    vb.memory = "2048"
  end
  #vb.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'ESP', '--vendorid', '0x1a86', '--productid', '0x7523']

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  #config.vm.network "forwarded_port", guest: 8888, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  #config.vm.network "forwarded_port", guest: 8888, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8888, host: 8888

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine


    # Customize the amount of memory on the VM:
    #vb.memory = "1024"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
