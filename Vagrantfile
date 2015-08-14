VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "precise64"
	config.vm.box_url = "http://files.vagrantup.com/precise64.box"
	config.vm.box_download_checksum_type = "sha256"
	config.vm.box_download_checksum = "9a8bdea70e1d35c1d7733f587c34af07491872f2832f0bc5f875b536520ec17e"

	config.vm.provider :virtualbox do |vbox, override|
		vbox.memory = 1024
		vbox.cpus = 2
	end

	config.vm.provider :vmware_fusion do |vmware, override|
		override.vm.box = "precise64_fusion"
		override.vm.box_url = "http://files.vagrantup.com/precise64_vmware_fusion.box"
    override.vm.box_download_checksum_type = "sha256"
    override.vm.box_download_checksum = "b79e900774b6a27500243d28bd9b1770e428faa3d8a3e45997f2a939b2b63570"
    vmware.vmx["memsize"] = "1024"
    vmware.vmx["numvcpus"] = "2"
  end

  config.ssh.forward_agent = true
  config.vm.network "private_network", ip: "192.168.10.200"
  config.vm.provision :shell, :inline => "apt-get update -q && cd /vagrant && ./setup.sh"

  share_prefix = "share-"
  Dir['../*/'].each do |fname|
    basename = File.basename(fname)
    if basename.start_with?(share_prefix)
      mount_path = "/" + basename[share_prefix.length..-1]
      puts "Mounting share for #{fname} at #{mount_path}"
      config.vm.synced_folder fname, mount_path
    end
  end

  unless Vagrant.has_plugin?("vagrant-rekey-ssh")
    warn "------------------- SECURITY WARNING -------------------"
    warn "Vagrant is insecure by default.  To secure your VM, run:"
    warn "    vagrant plugin install vagrant-rekey-ssh"
    warn "--------------------------------------------------------"
  end
end

Dir.glob('Vagrantfile.local.d/*').sort.each do |path|
  load path
end
Dir.glob('Vagrantfile.local').sort.each do |path|
  load path
end
