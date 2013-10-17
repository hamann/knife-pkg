require 'knife-pkg'
require 'knife-pkg/controllers/apt'

include Knife::Pkg

describe 'AptPackageController' do
  describe '#new' do
    it 'should create an instance of AptPkgCtrl' do
      p = AptPackageController.new('a', 'b', :h => 1)
      expect(p).to be_an_instance_of(AptPackageController)
      expect(p.node).to eq('a')
      expect(p.session).to eq('b')
      expect(p.options).to eq(:h => 1)
    end
  end

  describe '#dry_run_supported?' do
    it 'should return true' do
      p = AptPackageController.new(nil, nil, {})
      expect(p.dry_run_supported?).to eq true
    end
  end

  describe "#last_pkg_cache_update" do
    it 'should return a time object' do
      t = Time.now
      result = ShellCommandResult.new(nil,"2013-10-07 09:58:34.000000000 +0200\n",nil,nil)

      p = AptPackageController.new(nil, nil)
      p.stub(:exec).and_return(result)
      expect(p.last_pkg_cache_update).to be_an_instance_of Time
      expect(p.last_pkg_cache_update).to eq(Time.parse("2013-10-07 09:58:34.000000000 +0200")) 
    end
  end

  describe "#available_updates" do
    it 'should return an array' do
      p = AptPackageController.new(nil, nil)
      result = ShellCommandResult.new(nil,"bla\n base-files2 (7.1wheezy1 => 7.1wheezy2)\nbla",nil,nil)
      p.stub(:exec).and_return(result)
      packages = p.available_updates
      expect(packages).to be_an_instance_of Array
      expect(packages[0].name).to eq("base-files2")
      expect(packages[0].version).to eq("7.1wheezy2")
    end
  end

  describe "#installed_version" do
    it 'should return the installed version from internal list' do
      p = AptPackageController.new(nil, nil)
      output = "bla\n base-files (7.1wheezy1 => 7.1wheezy2)\nbla"
      p.parse_upgrade(output)
      expect(p).not_to receive(:exec)
      expect(p.installed_version(Package.new("base-files"))).to eq("7.1wheezy1")
    end

    it 'should return the installed version from dpkg' do
      p = AptPackageController.new(nil, nil)
      output = "bla\n base-files (7.1wheezy1 => 7.1wheezy2)\nbla"
      p.parse_upgrade(output)
      r = Struct.new(:stdout)
      output_exec = r.new("1.0.0\n")
      p.stub(:exec).and_return(output_exec)
      expect(p).to receive(:exec)
      expect(p.installed_version(Package.new("bla"))).to eq("1.0.0")
    end
  end

  describe "#parse_upgrade" do
    it 'should parse output from apt-get upgrade and return an array of packages' do
      stdout = <<-END.gsub(/^ {6}/, '')
      Reading package lists...
      Building dependency tree...
      Reading state information...
      The following packages will be upgraded:
         base-files (7.1wheezy1 => 7.1wheezy2)
         curl (7.26.0-1+wheezy3 => 7.26.0-1+wheezy4)
         dmsetup (1.02.74-7 => 1.02.74-8)
         dpkg (1.16.10 => 1.16.12)
         gnupg (1.4.12-7+deb7u1 => 1.4.12-7+deb7u2)
         gpgv (1.4.12-7+deb7u1 => 1.4.12-7+deb7u2)
         grub-common (1.99-27+deb7u1 => 1.99-27+deb7u2)
         grub-pc (1.99-27+deb7u1 => 1.99-27+deb7u2)
         grub-pc-bin (1.99-27+deb7u1 => 1.99-27+deb7u2)
         grub2-common (1.99-27+deb7u1 => 1.99-27+deb7u2)
         initscripts (2.88dsf-41 => 2.88dsf-41+deb7u1)
         libcurl3 (7.26.0-1+wheezy3 => 7.26.0-1+wheezy4)
         libdevmapper-event1.02.1 (1.02.74-7 => 1.02.74-8)
         libdevmapper1.02.1 (1.02.74-7 => 1.02.74-8)
         libxml2 (2.8.0+dfsg1-7+nmu1 => 2.8.0+dfsg1-7+nmu2)
         linux-headers-3.2.0-4-amd64 (3.2.46-1+deb7u1 => 3.2.51-1)
         linux-headers-3.2.0-4-common (3.2.46-1+deb7u1 => 3.2.51-1)
         linux-image-3.2.0-4-amd64 (3.2.46-1+deb7u1 => 3.2.51-1)
         linux-libc-dev (3.2.46-1+deb7u1 => 3.2.51-1)
         lvm2 (2.02.95-7 => 2.02.95-8)
         mutt (1.5.21-6.2 => 1.5.21-6.2+deb7u1)
         perl (5.14.2-21 => 5.14.2-21+deb7u1)
         perl-base (5.14.2-21 => 5.14.2-21+deb7u1)
         perl-modules (5.14.2-21 => 5.14.2-21+deb7u1)
         python (2.7.3-4 => 2.7.3-4+deb7u1)
         python-minimal (2.7.3-4 => 2.7.3-4+deb7u1)
         sysv-rc (2.88dsf-41 => 2.88dsf-41+deb7u1)
         sysvinit (2.88dsf-41 => 2.88dsf-41+deb7u1)
         sysvinit-utils (2.88dsf-41 => 2.88dsf-41+deb7u1)
         tzdata (2013c-0wheezy1 => 2013d-0wheezy1)
      30 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
      Need to get 49.9 MB of archives.
      After this operation, 864 kB disk space will be freed.
      Do you want to continue [Y/n]? Abort.
      END
      p = AptPackageController.new(nil, nil)
      packages = p.parse_upgrade(stdout)
      expect(packages.count).to eq(30)
      expect(packages[0].name).to eq("base-files")
      expect(packages[0].version).to eq("7.1wheezy2")
      expect(packages[29].name).to eq("tzdata")
      expect(packages[29].version).to eq("2013d-0wheezy1")
    end
  end
end
