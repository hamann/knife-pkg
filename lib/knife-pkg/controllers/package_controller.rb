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
require 'chef/knife'

module Knife
  module Pkg
    class PackageController

      attr_accessor :node
      attr_accessor :session
      attr_accessor :options
      attr_accessor :ui

      def initialize(node, session, opts = {})
        @node = node
        @session = session
        @options = opts
      end

      def self.ui
        @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
      end

      def sudo
        @options[:sudo] ? 'sudo ' : ''
      end

      ## ++ methods to implement
      
      # update the package cache 
      # e.g apt-get update
      def update_pkg_cache
        raise NotImplementedError
      end

      # returns the `Time` of the last package cache update
      def last_pkg_cache_update
        raise NotImplementedError
      end

      # returns the version string of the installed package
      def installed_version(package)
        raise NotImplementedError
      end

      # returns an `Array` of all available updates
      def available_updates
        raise NotImplementedError
      end

      # updates a package
      # should only execute a 'dry-run' if @options[:dry_run] is set
      # returns a ShellCommandResult
      def update_package!(package)
        raise NotImplementedError
      end

      ## ++ methods to implement
      

      def update_package_verbose!(package)
        result = update_package!(package)
        if @options[:dry_run] || @options[:verbose]
          ui.info(result.stdout)
          ui.error(result.stderr)
        end
      end

      def try_update_pkg_cache
        if Time.now - last_pkg_cache_update > 86400 # 24 hours
          @ui.info("Updating package cache...")
          update_pkg_cache
        end
      end

      def update_dialog(packages)
        return if packages.count == 0

        ui.info("\tThe following updates are available:") if packages.count > 0
        packages.each do |package|
          ui.info(ui.color("\t" + package.to_s, :yellow))
        end

        if UserDecision.yes?("\tDo you want to update all packages? [y|n]: ")
          ui.info("\tupdating...")
          packages.each do |p| 
            update_package_verbose!(p) 
          end
          ui.info("\tall packages updated!")
        else
          packages.each do |package|
            if UserDecision.yes?("\tDo you want to update #{package}? [y|n]: ")
              result = update_package_verbose!(package)
              ui.info("\t#{package} updated!")
            end
          end
        end
      end

      def self.list_available_updates(updates)
        updates.each do |update|
          ui.info(ui.color("\t" + update.to_s, :yellow))
        end
      end

      def self.update!(node, session, packages, opts)
        ctrl = self.init_controller(node, session, opts)

        auto_updates = packages.map { |u| Package.new(u) }
        updates_for_dialog = Array.new

        ctrl.try_update_pkg_cache
        available_updates = ctrl.available_updates

        available_updates.each do |avail|
          if auto_updates.select { |p| p.name == avail.name }.count == 0
            updates_for_dialog << avail
          else
            ui.info("\tUpdating #{avail.to_s}")
            ctrl.update_package_verbose!(avail)
          end
        end

        ctrl.update_dialog(updates_for_dialog)
      end

      def self.available_updates(node, session, opts = {})
        ctrl = self.init_controller(node, session, opts)
        ctrl.try_update_pkg_cache
        updates = ctrl.available_updates
        list_available_updates(updates)
      end

      def self.init_controller(node, session, opts)
        begin
          ctrl_name = ''
          if node.has_key?(:platform)
            ctrl_name = self.controller_name(node[:platform])
          else
            platform = self.platform_by_local_ohai(session, opts)
            ctrl_name = self.controller_name(platform)
          end
          require File.join(File.dirname(__FILE__), ctrl_name)
        rescue LoadError
          raise NotImplementedError, "I'm sorry, but #{node.platform} is not supported!"
        end
        ctrl = Object.const_get('Knife').const_get('Pkg').const_get("#{ctrl_name.capitalize}PackageController").new(node, session, opts)
        ctrl.ui = self.ui
        ctrl
      end

      def self.platform_by_local_ohai(session, opts)
        ShellCommand.exec("ohai platform| grep \\\"", session).stdout.strip.gsub(/\"/,'')
      end

      def self.controller_name(platform)
        case platform
        when 'debian', 'ubuntu'
          'apt'
        else
          platform
        end
      end
    end
  end
end
