require 'knife-pkg'

module Knife
  module Pkg
    class DebianPackageController < PackageController

      def initialize(node, session, opts = {})
        super(node, session, opts)
      end

      def update_pkg_cache
        ShellCommand.exec("#{sudo}apt-get update", @session)
      end

      def last_pkg_cache_update
        result = ShellCommand.exec("stat -c %y /var/lib/apt/periodic/update-success-stamp", @session)
        Time.parse(result.stdout.chomp)
      end

      def installed_version(package)
        ShellCommand.exec("dpkg -p #{package.name} | grep -i Version: | awk '{print $2}'").stdout.chomp
      end

      def available_updates
        packages = Array.new
        if !update_notifier_installed?
          raise RuntimeError, "Gna!! No update-notifier(-common) installed!? Go ahead, install it and come back!"
        else
          result = ShellCommand.exec("#{sudo}/usr/lib/update-notifier/apt_check.py -p", @session)
          result.stderr.split("\n").each do |item|
            package = Package.new(item)
            package.version = installed_version(package)
            packages << package
          end
        end
        packages
      end

      def update_notifier_installed?
          ShellCommand.exec("dpkg-query -W update-notifier-common 2>/dev/null || echo 'false'").stdout.chomp != 'false'
      end
    end
  end
end
