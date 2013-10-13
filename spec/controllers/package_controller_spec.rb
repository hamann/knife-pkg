require 'knife-pkg'

include Knife::Pkg

describe 'PackageController' do
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
      FakeNode = Struct.new(:platform)
      node = FakeNode.new("debian")
      PackageController.init_controller(node, nil, nil)
    end
  end
end
