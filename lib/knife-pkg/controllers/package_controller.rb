require 'knife-pkg'

module Knife
  module Pkg
    class PackageController

      attr_accessor :node
      attr_accessor :session
      attr_accessor :options

      def initialize(node, session, opts = {})
        @node = node
        @session = session
        @options = opts
      end

      def sudo
        @options[:sudo] ? 'sudo ' : ''
      end

      # update the package cache 
      # e.g apt-get update
      def update_pkg_cache
        raise NotImplementedError
      end

      # returns the time of the last package cache update
      def last_pkg_cache_update
        raise NotImplementedError
      end

      # returns the version of the installed package
      def installed_version(package)
        raise NotImplementedError
      end

      # returns an array of all available updates
      def available_updates
        raise NotImplementedError
      end

      # updates an array of packages
      # should only execute a 'dry-run' if @options[:dry_run] is set
      # should be verbose if opts[:verbose] and/or @options[:dry_run] is set
      def update!(packages)
        raise NotImplementedError
      end

      def self.update!(node, session, packages)
      end

      def self.show!(node, session, packages)
      end

      def self.init_controller(node, session, opts)
        begin
          ctrl_name = self.controller_name(node.platform)
          require File.join(File.dirname(__FILE__), ctrl_name)
        rescue LoadError
          raise NotImplementedError, "I'm sorry, but #{node.platform} is not supported!"
        end
        Object.const_get("#{ctrl_name.capitalize}PackageController").new(node, session, opts)
      end

      def self.controller_name(platform)
        case platform
        when 'debian', 'ubuntu'
          'debian'
        else
          platform
        end
      end
    end
  end
end
