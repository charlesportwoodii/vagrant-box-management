Vagrant.configure(2) do |config|
  config.vm.box_check_update = true
  
  config.vm.network "public_network"
  
  #config.ssh.insert_key = false
  
  config.vm.synced_folder ".", "/var/www", 
    id: "vagrant-root",
    owner: "vagrant", 
    group: "www-data", 
    mount_options: ["dmode=775,fmode=775"]
end
