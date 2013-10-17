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
    it 'should raise an error if update-notifier is not installed' do
      p = AptPackageController.new(nil, nil)
      p.stub(:update_notifier_installed?).and_return(false)
      expect{p.available_updates}.to raise_error(/update-notifier/)
    end

    it 'should return an array' do
      result = ShellCommandResult.new(nil, nil, "b\na\nc", nil)
      p = AptPackageController.new(nil, nil)
      p.stub(:exec).and_return(result)
      p.stub(:update_notifier_installed?).and_return(true)
      p.stub(:installed_version).and_return("1.0.0")
      p.stub(:update_version).and_return("2.0.0")

      updates = p.available_updates
      expect(updates).to be_an_instance_of Array
      expect(updates.count).to eq(3)
      expect(updates[0].name).to eq("a")
      expect(updates[1].name).to eq("b")
      expect(updates[2].name).to eq("c")
    end
  end
end
