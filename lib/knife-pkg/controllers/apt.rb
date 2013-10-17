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
    class AptPackageController < PackageController

      def initialize(node, session, opts = {})
        super(node, session, opts)
        @installed_packages = Array.new
      end

      def dry_run_supported?
        true
      end

      def update_pkg_cache
        exec("#{sudo}apt-get update")
      end

      def last_pkg_cache_update
        result = nil
        begin
          result = exec("#{sudo} stat -c %y /var/lib/apt/lists")
          Time.parse(result.stdout.chomp)
        rescue RuntimeError => e
          e.backtrace.each { |l| Chef::Log.debug(l) }
          Chef::Log.warn(e.message)
          Time.now - (max_pkg_cache_age + 100)
        end
      end

      def installed_version(package)
        package = @installed_packages.select { |p| p.name == package.name }.first || Package.new("")
        if !package.name.empty?
          version = package.version
        else
          # fallback
          version = exec("dpkg -p #{package.name} | grep -i Version: | awk '{print $2}' | head -1").stdout.chomp
        end
        version
      end

      def update_version(package)
        exec("#{sudo} apt-cache policy #{package.name} | grep Candidate | awk '{print $2}'").stdout.chomp
      end

      def available_updates
        parse_upgrade(exec("#{sudo} apt-get dist-upgrade -V -s | egrep -v \"^(Conf|Inst)\"").stdout)
      end

      def parse_upgrade(upgrade_line)
        result = Array.new
        rx = Regexp.new(/\s+(?<name>\S+)\s\((?<installed>.+)\s=>\s(?<new>.+)\)/)
        upgrade_line.split("\n").each do |line|
          match = rx.match(line)
          unless match.nil?
            result << Package.new(match[:name], match[:new])
            @installed_packages << Package.new(match[:name], match[:installed])
          end
        end
        result
      end

      def update_package!(package)
        cmd_string = "#{sudo} DEBIAN_FRONTEND=noninteractive apt-get install #{package.name} -y -o Dpkg::Options::='--force-confold'"
        cmd_string += " -s" if @options[:dry_run]
        exec(cmd_string)
      end
    end
  end
end
