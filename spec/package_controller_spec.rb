require 'knife-pkg'

include Knife::Pkg

describe 'PackageController' do
  describe '#new' do
  end

  describe '#sudo' do
    it 'should return sudo prefix' do
      p = PackageController.new(nil, :sudo => true)
      expect(p.sudo).to eq("sudo ")
    end

    it 'should return no sudo prefix' do
      p = PackageController.new(nil)
      expect(p.sudo).to eq("")
    end
  end
end
