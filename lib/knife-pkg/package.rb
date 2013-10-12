require 'knife-pkg'

module Knife
  module Pkg
    class Package
      attr_accessor :name, :version

      def initialize(name, version = '0.0')
        @name = name.strip
        @version = version
      end

      def to_s
        @name + (version_to_s == '' ? '' : " #{version_to_s}")
      end

      def version_to_s
        if @version.to_s != '0.0'
          "(#{@version})"
        else
          ''
        end
      end
    end
  end
end
