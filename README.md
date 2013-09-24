# vagrant-lemonstand

A local development environement built using [Vagrant](http://vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) using puppet and command line provisioning. This will build a local environment for you to start building your own [Lemonstand](http://lemonstand.com) application. 

## Tools

### Vagrant

Create and configure lightweight, reproducible, and portable development environments. A command line wrapper for VirtualBox.

### Puppet

Puppet manages your servers: describe machine configurations in an easy-to-read declarative language, and Puppet will bring your systems into the desired state and keep them there.

## Installation

Install Vagrant + Virtualbox then run the following commands:

	git clone git@github.com:lemonoid/vagrant-lemonstand.git
	cd vagrant-lemonstand
	cp puppet/modules/params/manifests/init.dist.pp puppet/modules/params/manifests/init.pp

Edit the configuration file with your favorite editor at:

	puppet/modules/params/manifests/init.pp

When you are finished run:

	vagrant up