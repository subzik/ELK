Vagrant.configure(2) do |config|
  (1..2).each do |i|
    config.vm.define "ELK#{i}" do |el|
      el.vm.box = "sbeliakou/centos"
      el.vm.box_check_update = false
      el.vm.hostname = "ELK#{i}"
      el.vm.network "private_network", ip: "192.168.0.5#{i}"
      el.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "2048"
        vb.name = "ELK#{i}"
      end
      el.vm.provision :shell, :path => "install_ELK#{i}.sh"
    end
  end
end
