require 'knife-pkg'

include Knife::Pkg

describe 'PackageController' do
  before :each do
    @ui = Object.new
    @ui.stub(:info)
    @ui.stub(:error)
  end

  describe '#new' do
  end

  describe '#sudo' do
    it 'should return sudo prefix' do
      p = PackageController.new(nil, nil, :sudo => true)
      expect(p.sudo).to eq("sudo ")
    end

    it 'should return no sudo prefix' do
      p = PackageController.new(nil, nil)
      expect(p.sudo).to eq("")
    end
  end

  describe '.init_controller' do
    it 'should initialize the right package controller' do
      node = Hash.new

      node[:platform] = 'debian'
      ctrl = PackageController.init_controller(node, nil, nil)
      expect(ctrl).to be_an_instance_of AptPackageController
    end
  end

  describe '#update_info' do
    it 'should return an array of strings with package update information' do
      ctrl = PackageController.new(nil, nil)
      pkg = Package.new("a", "1.0.1")
      pkg2 = Package.new("b", "2.0.2")

      ctrl.stub(:installed_version).with(pkg).and_return("1.0.0")
      ctrl.stub(:installed_version).with(pkg2).and_return("2.0.0")


      strings = ctrl.update_info([pkg, pkg2])
      expect(strings.count).to eq(2)
      expect(strings[0]).to match(/a.+1\.0\.1.+1\.0\.0/)
      expect(strings[1]).to match(/b.+2\.0\.2.+2\.0\.0/)
    end
  end

  describe '#update_package_verbose!' do
    it 'should not print stdout and stderr dry_run or verbose are not set' do
      ctrl = PackageController.new(nil, {})
      ctrl.ui = @ui
      r = Struct.new(:stdout, :stderr)
      result = r.new("a", "b")

      ctrl.stub(:update_package!).and_return(result)
      expect(ctrl.ui).to_not receive(:info)
      expect(ctrl.ui).to_not receive(:error)
      ctrl.update_package_verbose!([0])
    end

    it 'should print stdout and stderr if dry_run is set' do
      ctrl = PackageController.new(nil, {})
      ctrl.ui = @ui
      r = Struct.new(:stdout, :stderr)
      result = r.new("a", "b")

      ctrl.options[:dry_run] = true
      ctrl.stub(:update_package!).and_return(result)
      expect(ctrl.ui).to receive(:info).with("a")
      expect(ctrl.ui).to receive(:error).with("b")
      ctrl.update_package_verbose!([0])
    end

    it 'should print stdout and stderr if verbose is set' do
      ctrl = PackageController.new(nil, {})
      ctrl.ui = @ui

      r = Struct.new(:stdout, :stderr)
      result = r.new("a", "b")

      ctrl.options[:dry_run] = true
      ctrl.stub(:update_package!).and_return(result)
      expect(ctrl.ui).to receive(:info).with("a")
      expect(ctrl.ui).to receive(:error).with("b")
      ctrl.update_package_verbose!([0])
    end
  end

  describe "#try_update_pkg_cache" do
    it 'should call update_pkg_cache' do
      ctrl = PackageController.new(nil, nil)
      ctrl.ui = @ui
      ctrl.stub(:last_pkg_cache_update).and_return(Time.now - 86500)
      expect(ctrl).to receive(:update_pkg_cache)
      ctrl.try_update_pkg_cache
    end
  end
end
