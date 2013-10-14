class Chef
  class Knife
    class PkgShowUpdates < PkgBase

      banner 'knife pkg show updates QUERY (options)'

      deps do
        require 'net/ssh'
        require 'net/ssh/multi'
        require 'chef/knife/ssh'
        require 'knife-pkg'
      end

      option :ssh_user,
        :short => '-x USERNAME',
        :long => '--ssh-user USERNAME',
        :description => 'The ssh username'

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
        :description => "The attribute to use for opening the ssh connection - default is fqdn"

      option :manual,
        :short => "-m",
        :long => "--manual-list",
        :boolean => true,
        :description => "QUERY is a space separated list of servers",
        :default => false

      def run
        super
      end
      
      def process(node, session)
        ui.info("===> " + extract_nested_value(node, config[:attribute]))
        ::Knife::Pkg::PackageController.available_updates(node, session, :sudo => true) # TODO apply sudo by configuriation
      end
    end
  end
end
