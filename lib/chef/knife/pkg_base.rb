class Chef
  class Knife
    module PkgBase

      def self.load_deps
      end

      def self.included(includer)
        includer.class_eval do
          category 'pkg'

          deps { Chef::Knife::PkgBase.load_deps }

          option :username,
            :short => '-x USERNAME',
            :long => '--ssh-user USERNAME',
            :description => 'The ssh username',
            :proc => Proc.new { |api_key| Chef::Config[:knife][:ssh_user] = api_key }
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end
    end
  end
end
