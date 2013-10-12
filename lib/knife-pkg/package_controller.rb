require 'knife-pkg'

module Knife
  module Pkg
    class PackageController

      attr_accessor :session
      attr_accessor :options

      def initialize(session, opts = {})
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
    end
  end
end
