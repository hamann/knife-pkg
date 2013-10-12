require 'knife-pkg'

include Knife::Pkg

describe 'Package' do
  describe '#new' do
    it 'should create an instance of Package' do
      p = Package.new('test')
      expect(p).to be_an_instance_of Package
      expect(p.version).to eq('0.0')
      expect(p.name).to eq('test')
    end
  end

  describe '#version_to_s' do
    it 'should return the version' do
      p = Package.new('', '0.0.1')
      expect(p.version_to_s).to eq('(0.0.1)')
    end

    it 'should return an empty string if version is not defined' do
      p = Package.new('')
      expect(p.version_to_s).to eq('')
    end
  end

  describe '#to_s' do
    it 'should return package name with version' do
      p = Package.new('test','0.0.1')
      expect(p.to_s).to eq('test (0.0.1)')
    end

    it 'should return package without version' do
      p = Package.new('test')
      expect(p.to_s).to eq('test')
    end
  end

  
end
