boxes = {
  :debian => { :image => "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_debian-7.1.0_provisionerless.box" },
  :ubuntu => { :image => "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box" },
  :centos => { :image => "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box" },
  :fedora => { :image => "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode-fedora-19_provisionerless.box" }
}

Vagrant::configure("2") do |config|
  boxes.each do |name, options|
    config.omnibus.chef_version = 'latest'
    config.berkshelf.enabled = false

    config.vm.define name do |box_config|
      box_config.vm.box = name.to_s
      box_config.vm.box_url = options[:image]
    end
  end
end
