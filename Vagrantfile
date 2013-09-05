# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  config.vm.hostname = "devbox"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 3306, host: 3306
  config.vm.network :private_network, ip: "192.168.33.10"
  # config.vm.network :public_network
  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.synced_folder "./data/db", "/tmp"
  config.vm.synced_folder "./files", "/srv", :owner => "www-data", :extra => "dmode=775,fmode=774"
  config.vm.provision :shell, :inline => "echo \"America/Chicago\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    #vb.gui = true
    # Clock time
    vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
    # Change memory
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file = "base.pp"
    # puppet.options = "--verbose --debug"
    # puppet.options = "--verbose"
  end

  # fix hang after `Waiting for VM to boot. This can take a few minutes.`
  # https://github.com/mitchellh/vagrant/issues/455#issuecomment-1740526
  config.ssh.max_tries = 250
  config.ssh.forward_agent = true
  # config.ssh.private_key_path = "~/.ssh/id_rsa"
  # http://superuser.com/questions/570174/having-vagrant-provisioning-clone-a-repository/570775#570775
end
