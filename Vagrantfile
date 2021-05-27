
Vagrant.configure("2") do |config|

  config.vm.box = "ivan_balandzin/mntlab-troubleshooting"
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "512"
  end

  config.vm.provision 'shell', path: "provision.sh"

end
