VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/centos-7.1"
  config.vm.boot_timeout = 600
  config.vm.box_check_update = false
  config.vm.synced_folder "./shared", "/shared"
  
  (1..3).each do |i|
    config.vm.define "mdb#{i}" do |mongod|
      mongod.vm.provider "virtualbox" do |vb|
        vb.name = "mdbscram#{i}"
        vb.memory = 512
      end
      mongod.vm.network :private_network, ip: "192.168.14.15#{i}"
      mongod.vm.hostname = "mdb#{i}.vagrant.dev"
      mongod.vm.provision :shell, :inline => "/shared/scripts/setupmdb.sh mdb#{i}"
    end
  end
end