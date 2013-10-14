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


class Chef
  class Knife
    class PkgBase < Knife::Ssh

      def run
        # necessary for Knife::Ssh
        @longest = 0
        config[:manual] = false 

        configure_attribute
        configure_sudo
        configure_user
        configure_identity_file
        configure_gateway
        configure_session
        process_each_node
      end

    end

    def configure_sudo
      config[:sudo_required] = Chef::Config[:knife][:pkg_sudo_required] ||
                       config[:sudo_required]
    end

    def pkg_options
      pkg_options = Hash.new
      pkg_options[:sudo] = config[:sudo_required]
      pkg_options[:verbose] = config[:verbose] || config[:dry_run] || config[:pkg_verbose]
      pkg_options
    end

    def process_each_node
      cur_session = nil
      begin
        session.servers.each do |server|
          node = node_by_hostname(server.host)
          if node
            cur_session = server.session(true)
            process(node, cur_session)
            cur_session.close
          else
            ui.fatal("Could not find any node for server #{server.host}")
            exit 1
          end
        end
      ensure
        if cur_session
          cur_session.close unless cur_session.closed?
        end
      end
    end

    def node_by_hostname(hostname)
      node = nil
      @action_nodes.each do |n|
        if hostname_by_attribute(n) == hostname
          node = n
          break
        end
      end
      node
    end

    def hostname_by_attribute(node)
      if !config[:override_attribute] && node[:cloud] and node[:cloud][:public_hostname]
        i = node[:cloud][:public_hostname]
      elsif config[:override_attribute]
        i = extract_nested_value(node, config[:override_attribute])
      else
        i = extract_nested_value(node, config[:attribute])
      end
    end
  end
end
