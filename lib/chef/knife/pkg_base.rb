class Chef
  class Knife
    module PkgBase

      def self.load_deps
        require 'knife-pkg'
      end

      def self.included(includer)
        includer.class_eval do
          category 'pkg'

          deps { Chef::Knife::PkgBase.load_deps }

          option :ssh_user,
            :short => '-x USERNAME',
            :long => '--ssh-user USERNAME',
            :description => 'The ssh username',
            :proc => Proc.new { |api_key| Chef::Config[:knife][:ssh_user] = api_key }

          option :ssh_port,
            :short => "-p PORT",
            :long => "--ssh-port PORT",
            :description => "The ssh port",
            :default => "22",
            :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

          option :identity_file,
            :short => "-i IDENTITY_FILE",
            :long => "--identity-file IDENTITY_FILE",
            :description => "The SSH identity file used for authentication"

          option :no_host_key_verify,
            :long => "--no-host-key-verify",
            :description => "Disable host key verification",
            :boolean => true,
            :default => false

          option :attribute,
            :short => "-a ATTR",
            :long => "--attribute ATTR",
            :description => "The attribute to use for opening the ssh connection - default is fqdn",
            :default => "fqdn"

        end
      end

      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end
    end
  end
end
