class Chef
  class Knife
    class PkgList < Knife
      include Knife::PkgBase

      banner 'knife pkg list (options)'

      def run
        puts Chef::Config[:knife]
      end
    end
  end
end
