require 'knife-pkg'
require 'knife-pkg/controllers/yum'

include Knife::Pkg

describe 'YumPackageController' do
  describe '#new' do
    it 'should create an instance of YumPkgCtrl' do
      p = YumPackageController.new('a', 'b', :h => 1)
      expect(p).to be_an_instance_of(YumPackageController)
      expect(p.node).to eq('a')
      expect(p.session).to eq('b')
      expect(p.options).to eq(:h => 1)
    end
  end

  describe "#dry_run_supported?" do
    it 'should return false' do
      p = YumPackageController.new(nil, nil, {})
      expect(p.dry_run_supported?).to eq false
    end
  end

  describe "#last_pkg_cache_update" do
    it 'should return a time object' do
      p = YumPackageController.new(nil, nil)
      expect(p.last_pkg_cache_update).to be_an_instance_of Time
      expect(p.last_pkg_cache_update.to_s).to eq(Time.now.to_s)
    end
  end

  describe "#installed_version" do
    it 'should return the installed version of a package as string' do
      r = Struct.new(:stdout)
      result = r.new("3.2.29-40.el6.centos\n")

      p = YumPackageController.new(nil, nil)
      p.stub(:exec).and_return(result)
      expect(p).to receive(:sudo)
      expect(p.installed_version(Package.new("a"))).to eq("3.2.29-40.el6.centos")
    end
  end

  describe "#update_version" do
    it 'should return the installed version of a package as string' do
      r = Struct.new(:stdout)
      result = r.new("3.2.29-40.el6.centos\n")

      p = YumPackageController.new(nil, nil)
      p.stub(:exec).and_return(result)
      expect(p).to receive(:sudo)
      expect(p.update_version(Package.new("a"))).to eq("3.2.29-40.el6.centos")
    end
  end

  describe "#available_updates" do
    it 'should return an array of packages' do
      r = Struct.new(:stdout)
      result = r.new("   \nabrt.x86_64 2.0.8-16.el6.centos.1\nabrt-addon-ccpp.x86_64 2.0.8-16.el6.centos.1\n")

      p = YumPackageController.new(nil, nil)
      p.stub(:exec).and_return(result)

      expect(p).to receive(:sudo)

      updates = p.available_updates
      expect(updates.count).to eq(2)
      expect(updates[0].name).to eq("abrt.x86_64")
      expect(updates[0].version).to eq("2.0.8-16.el6.centos.1")
      expect(updates[1].name).to eq("abrt-addon-ccpp.x86_64")
      expect(updates[1].version).to eq("2.0.8-16.el6.centos.1")
    end
  end

  describe "#update_package!" do
    it 'should update a package and return a ShellCommandResult' do
      p = YumPackageController.new(nil, nil)
      r = ShellCommandResult.new(nil,nil, "1\n2\n3", nil)
      p.stub(:exec).and_return(r)
      expect(p.update_package!(Package.new("a"))).to eq(r)
    end
  end
end

