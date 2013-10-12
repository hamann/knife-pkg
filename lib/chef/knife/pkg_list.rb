require 'chef/knife/pkg_base'

class Chef
  class Knife
    class PkgList < Knife
      include Knife::PkgBase

      banner 'knife pkg list (options)'

      def run
        puts 'hello pkg!'
      end
    end
  end
end
