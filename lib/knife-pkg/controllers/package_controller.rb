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

      # updates a package
      # should only execute a 'dry-run' if @options[:dry_run] is set
      # returns a ShellCommandResult
      def update_package!(package)
        raise NotImplementedError
      end

      def self.update!(node, session, packages, opts)
        ctrl = self.init_controller(node, session, opts)
        packages.each do |pkg|
          result = ctrl.update_package!(package)
          if @options[:dry_run] || @options[:verbose]
            p result.stdout # TODO ui
            p result.stderr # TODO ui
          end
        end
      end

      def self.available_updates(node, session, opts)
        ctrl = self.init_controller(node, session, opts)
        updates = ctrl.available_updates
        updates.each do |update|
          p update # TODO ui
        end
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
