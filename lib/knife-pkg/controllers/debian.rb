#
# Copyright 2013, Holger Amann <holger@fehu.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


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
        ShellCommand.exec("dpkg -p #{package.name} | grep -i Version: | awk '{print $2}'", @session).stdout.chomp
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

      def update_package!(package)
        cmd_string = "#{sudo} DEBIAN_FRONTEND=noninteractive apt-get install #{package.name} -y -o Dpkg::Options::='--force-confold'"
        cmd_string += " -s" if @options[:dry_run]
        ShellCommand.exec(cmd_string, @session)
      end

      def update_notifier_installed?
          ShellCommand.exec("dpkg-query -W update-notifier-common 2>/dev/null || echo 'false'", @session).stdout.chomp != 'false'
      end
    end
  end
end
