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
      expect(p.sudo).to eq("sudo -p 'knife sudo password: ' ")
    end

    it 'should return no sudo prefix' do
      p = PackageController.new(nil, nil)
      expect(p.sudo).to eq("")
    end
  end

  describe '#exec' do
    it 'should call ShellCommand and return a ShellCommandResult' do
      p = PackageController.new(nil, 'a')
      p.ui = @ui
      cmd = "ls -l"
      r = Struct.new(:stdout, :stderr)
      result = r.new('a', 'b')
      p.stub(:get_password).and_return('test')
      ShellCommand.stub(:exec).and_return(r)
      expect(ShellCommand).to receive(:exec)
      expect(p.exec(cmd)).to eq(r)
    end
  end

  describe '#get_password' do
    it 'should prompt for password only the first time' do
      p = PackageController.new(nil, 'a')
      p.ui = @ui
      p.ui.stub(:ask).and_return('test')
      expect(p).to receive(:prompt_for_password).exactly(1).times
      p.get_password
    end
  end

  describe '.init_controller' do
    it 'should initialize the right package controller if node[:platform_family] is not set' do
      node = Hash.new
      node[:platform_family] = 'debian'
      expect(PackageController).to_not receive(:platform_family_by_local_ohai)
      ctrl = PackageController.init_controller(node, nil, nil)
      expect(ctrl).to be_an_instance_of AptPackageController
     end

    it 'should call ohai if node[:platform_family] is not set' do
      PackageController.stub(:platform_family_by_local_ohai).and_return('debian')
      expect(PackageController).to receive(:platform_family_by_local_ohai)
      ctrl = PackageController.init_controller({}, nil, nil)
      expect(ctrl).to be_an_instance_of AptPackageController
    end

    it 'should raise an error if platform family could not be mapped' do
      node = { :platform_family => 'suse' }
      expect{PackageController.init_controller(node, nil, {})}.to raise_error(NotImplementedError)
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
    it 'should raise an error if dry run is not supported' do
      ctrl = PackageController.new(nil, nil, :dry_run => true)
      expect{ctrl.update_package_verbose!([])}.to raise_error(NotImplementedError)
    end

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
      ctrl.stub(:dry_run_supported?).and_return(true)
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
      ctrl.stub(:dry_run_supported?).and_return(true)
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
      ctrl.stub(:last_pkg_cache_update).and_return(Time.now - PackageController::ONE_DAY_IN_SECS)
      expect(ctrl).to receive(:update_pkg_cache)
      ctrl.try_update_pkg_cache
    end
  end

  describe '.list_available_updates' do
    it 'should list available updates' do
      p = Package.new('1'); p2 = Package.new('p2')
      Chef::Knife::UI.any_instance.stub(:info)
      PackageController.list_available_updates([p,p2])
    end
  end

  describe '.platform_family_by_local_ohai' do
    it 'should call ohai to determine the platform family' do
      r = Struct.new(:stdout)
      result = r.new("  \"mac_os_x\"")
      ShellCommand.stub(:exec).and_return(result)
      expect(ShellCommand).to receive(:exec)
      expect(PackageController.platform_family_by_local_ohai(nil, nil)).to eq("mac_os_x")
    end
  end

  describe '.update!' do
    it 'should install available updates' do
      node = { :platform_family => 'debian' }
      packages = ["a","b","c"]
      package_for_dialog = Package.new("d")
      available_updates = [ Package.new("a"), Package.new("b"), package_for_dialog ]

      ctrl = PackageController.new(node, nil, {})
      ctrl.ui = @ui
      Chef::Knife::UI.any_instance.stub(:info)

      PackageController.stub(:init_controller).with(node, nil, {}).and_return(ctrl)
      ctrl.stub(:try_update_pkg_cache)
      ctrl.stub(:available_updates).and_return(available_updates)
      ctrl.stub(:update_package_verbose!).with([Package.new("a"), Package.new("b")])
      ctrl.stub(:dry_run_supported?).and_return(true)
      ctrl.stub(:update_dialog).with([package_for_dialog])

      expect(PackageController).to receive(:init_controller).with(node, nil, {})
      expect(ctrl).to receive(:try_update_pkg_cache)
      expect(ctrl).to receive(:available_updates)
      expect(ctrl).to receive(:update_package_verbose!).exactly(2).times
      expect(ctrl).to receive(:update_dialog).with([package_for_dialog])
      PackageController.update!(node, nil, packages, {})
    end
  end
end
