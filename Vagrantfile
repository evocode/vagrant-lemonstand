# -*- mode: ruby -*-
# vi: set ft=ruby :

dir = Dir.pwd
vagrant_dir = File.expand_path(File.dirname(__FILE__))

Vagrant.configure("2") do |config|

  # Store the current version of Vagrant for use in conditionals when dealing
  # with possible backward compatible issues.
  vagrant_version = Vagrant::VERSION.sub(/^v/, '')

  # Default Ubuntu Box
  #
  # This box is provided by Vagrant at vagrantup.com containing the 
  # Ubuntu 12.0.4 Precise 32 bit release. Once downloaded it is cached
  # for future use.
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  config.vm.hostname = "devbox"

  # Ports and IP Address
  # 
  # These are the port forward and ip address settings. The default ip
  # is located at 192.168.33.10
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 3306, host: 3306
  config.vm.network :private_network, ip: "192.168.33.10"

  # Synced Folders
  # 
  # The ./files folder will be mapped to the /srv/www/ folder inside of the
  # VM. Put all of your project files here that you want to access through
  # the web server.
  if vagrant_version >= "1.3.0"
    config.vm.synced_folder "./files", "/srv", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
  else
    config.vm.synced_folder "./files", "/srv", :owner => "www-data", :extra => "dmode=775,fmode=774"
  end

  # Time Zone
  # 
  # This fixes the timezone on the server.
  config.vm.provision :shell, :inline => "echo \"America/Chicago\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

  # Virtual Box Configuraiton
  # 
  # This section is the virtualbox configuration options.
  config.vm.provider :virtualbox do |vb|
    # Boot the GUI
    #vb.gui = true
    
    # Clock time
    vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]

    # Change memory
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  
  # Puppet Provisioning
  # 
  # This section is the puppet configuration options.
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file = "base.pp"
    # puppet.options = "--verbose --debug"
    # puppet.options = "--verbose"
  end

  # Forward Agent
  #
  # Enable agent forwarding on vagrant ssh commands. This allows you to use identities
  # established on the host machine inside the guest. See the manual for ssh-add
  config.ssh.forward_agent = true

end
