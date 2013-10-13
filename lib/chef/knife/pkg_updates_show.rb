class Chef
  class Knife
    class PkgUpdatesShow < Knife
      include Knife::PkgBase

      banner 'knife pkg updates show QUERY (options)'

      def run
        puts Chef::Config[:knife]
      end
    end
  end
end
