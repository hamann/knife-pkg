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
    class YumPackageController < PackageController

      def initialize(node, session, opts = {})
        super(node, session, opts)
      end

      def update_pkg_cache
        # necessary?
      end

      def last_pkg_cache_update
        return Time.now # ok?
      end

      def installed_version(package)
        ShellCommand.exec("#{sudo}yum list installed | egrep \"^#{package.name}\" | awk '{print $2}'").chomp
      end

      def available_updates
        packages = Array.new
        result = ShellCommand.exec("#{sudo}yum check-update -q| awk '{ print $1, $2 }'", @session)
        result.stdout.split("\n").each do |item|
          next unless item.match(/^\s+$/).nil?
          name, version = item.split(" ")
          package = Package.new(name, version)
          packages << package
        end
        packages
      end

      def update_package!(package)
        raise NotImplementedError, "\"dry run\" isn't supported for yum!" if @options[:dry_run]
        cmd_string = "#{sudo}yum -d0 -e0 -y install #{package.name}"
        ShellCommand.exec(cmd_string, @session)
      end
    end
  end
end
