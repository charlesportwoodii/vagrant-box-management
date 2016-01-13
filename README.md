# Vagrant Box Management Instructions

The following document outlines how to update Vagrant boxes and package them for release on [VagrantCloud](https://www.vagrantcloud.com). These instructions are specific for the boxes that [I provide](https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=&q=charlesportwoodii) for PHP 5.6 and PHP 7, but should be trivial to adapt for your own purposes should I need them. These instructions are primarily written for my own reference.


1. Verify Vagrant and VirtualBox are running the latest versions
2. For each box, create a new directory and within it use Vagrant to download, install, and up the box.

    ```
    mkdir -p box
    cd box
    vagrant init charlesportwoodii/php7_trusty64
    # vagrant init charlesportwoodii/php56_trusty64
    vagrant up --provider virtualbox
    ```
    > Note that these boxes connect to a bridge adapter - so if you have more than 1 active outbound network adapter, Vagrant will need to specify it.
    
3. Use the fullowing script to update the box.

    ```
    curl https://raw.githubusercontent.com/charlesportwoodii/vagrant-box-management/master/scripts/update.sh | sudo sh
    ```
    > Script is obviously simplified, don't pipe the internet through your vagrant box and distribute it unless you verify the script is what it claims to be.
    
    This script takes care of several tasks, most importantly updating apt packages, clearing apt cache, and zeroing the remaining disk space to aid in disk compression. This command will also wipe the history, any log files, and reset the ssh key to the default Vagrant one to be reset the next time ```vagrant up``` is run.
    
    > After running this script, it is very important that you don't run any other commands, as doing so could change the ssh key or add information to the history.

4. Exit the box and run ```vagrant halt``` to stop the box.
5. Copy and compress the ``vmdk``` image. This is important and Vagrant Boxes can get rather large after updating packages

    ```
    # Convert the box to VDI for compression
    vboxmanage clonehd /path/to/<generated_box_dir>/box-disk1.vmdk box-disk1.vdi --format VDI
    
    # Compress the VDI
    vboxmanage modifyhd --compact box-disk1.vdi
    
    # Reconvert the box to VMDK
    vboxmanage clonehd box-disk1.vdi box-disk1.vmdk --format VMDK
    
    # Move the box back to the virtual machine directory
    mv box-disk1.vmdk /path/to/<generated_box_dir>
    ```
    
    > Cloning the box can confuse Virtualbox and prevent the ```package``` command from running. After cloning the box, go to File > Virtual Machine Manager, and release any boxes that are in an errored state, then go into the generated virtual machine and verify the generated ```vmdk`` disk is present and attached.
    
6. Modify ```Vagrantfile``` with the following arguments to automatically configure port forwarding and bridged networking

    ```
    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "public_network"
    ```

7. Package the box

    ```
    vagrant package --base <generated_box_name> --vagrantfile ./Vagrantfile --output <file>.box
    ```
    
    Assuming all went well, you should have a file called ```<file>.box``` present on disk that you can upload to Atlas. The box should be ~750MB depending upon what was packaged.
