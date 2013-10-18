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

      ONE_DAY_IN_SECS = 86500

      attr_accessor :node
      attr_accessor :session
      attr_accessor :options
      attr_accessor :ui

      def initialize(node, session, opts = {})
        @node = node
        @session = session
        @options = opts
      end

      
      class << self

        def list_available_updates(updates)
          updates.each do |update|
            ui.info(ui.color("\t" + update.to_s, :yellow))
          end
        end

        def ui
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
        end

        # Connects to the node, updates packages (defined with param `packages`) without confirmation, all other available updates with confirmation
        # @param [Hash] node the node
        # @option node [String] :platform_family platform of the node, e.g. `debian`. if not set, `ohai` will be executed
        # @param [Session] session the ssh session to be used to connect to the node
        # @param [Array<String>] packages name of the packages which should be updated without confirmation
        # @param [Hash] opts the options
        # @option opts [Boolean] :dry_run whether the update should only be simulated (if supported by the package manager)
        # @option opts [Boolean] :verbose whether the update process should be more verbose
        # @option opts [Boolean] :yes whether all available updates should be installed without confirmation
        def update!(node, session, packages, opts)
          ctrl = self.init_controller(node, session, opts)

          auto_updates = packages.map { |u| Package.new(u) }
          updates_for_dialog = Array.new

          ctrl.try_update_pkg_cache
          available_updates = ctrl.available_updates

          # install all available packages
          if opts[:yes]
            auto_updates = available_updates
          end

          # install packages in auto_updates without confirmation, 
          # but only if they are available as update 
          # don't install packages which aren't installed 
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

        def available_updates(node, session, opts = {})
          ctrl = self.init_controller(node, session, opts)
          ctrl.try_update_pkg_cache
          updates = ctrl.available_updates
          list_available_updates(ctrl.update_info(updates))
        end

        def init_controller(node, session, opts)
          platform_family = node[:platform_family] || self.platform_family_by_local_ohai(session, opts)
          ctrl_name = PlatformFamily.map_to_pkg_ctrl(platform_family)
          raise NotImplementedError, "I'm sorry, but #{node[:platform_family]} is not supported!" if ctrl_name == 'unknown'

          Chef::Log.debug("Platform Family #{platform_family} detected, using #{ctrl_name}")
          require File.join(File.dirname(__FILE__), ctrl_name)
          ctrl = Object.const_get('Knife').const_get('Pkg').const_get("#{ctrl_name.capitalize}PackageController").new(node, session, opts)
          ctrl.ui = self.ui
          ctrl
        end

        def platform_family_by_local_ohai(session, opts)
          ShellCommand.exec("ohai platform_family| grep \\\"", session).stdout.strip.gsub(/\"/,'')
        end
      end

      ## ++ methods to implement
      
      # update the package cache 
      # e.g apt-get update

      def dry_run_supported?
        false
      end

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

      # returns the version string of the available update for a package
      def update_version(package)
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


      def sudo
        @options[:sudo] ? 'sudo ' : ''
      end

      def exec(cmd)
        ShellCommand.exec(cmd, @session)
      end

      def max_pkg_cache_age
        options[:max_pkg_cache_age] || ONE_DAY_IN_SECS
      end
      
      def update_info(packages)
        result = []
        packages.each do |pkg|
          installed_version = installed_version(pkg)
          result << "#{pkg.name} (new: #{pkg.version} | installed: #{installed_version})"
        end
        result
      end

      def update_package_verbose!(package)
        raise NotImplementedError, "\"dry run\" isn't supported for this platform! (maybe a bug)" if @options[:dry_run] && !dry_run_supported?

        result = update_package!(package)
        if @options[:dry_run] || @options[:verbose]
          ui.info(result.stdout)
          ui.error(result.stderr) unless result.stderr.empty?
        end
      end

      def try_update_pkg_cache
        if Time.now - last_pkg_cache_update > max_pkg_cache_age 
          @ui.info("Updating package cache...")
          update_pkg_cache
        end
      end

      def update_dialog(packages)
        return if packages.count == 0

        ui.info("\tThe following updates are available:") 
        PackageController.list_available_updates(update_info(packages))

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
    end
  end
end
