class Chef
  class Knife
    class PkgBase < Knife::Ssh

      def run
        @longest = 0
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
