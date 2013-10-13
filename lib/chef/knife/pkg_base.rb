class Chef
  class Knife
    class PkgBase < Knife::Ssh

      def run
        @longest = 0
        configure_attribute
        configure_user
        configure_identity_file
        configure_gateway
        configure_session
        process_each_node
      end

    end

    def process_each_node
      @action_nodes.each do |node|
        host_spec = host_spec_by_node(node)
        subsession = session.on(host_spec)
        process(node, session)
      end
    end

    def host_spec_by_node(node)
      if !config[:override_attribute] && node[:cloud] and node[:cloud][:public_hostname]
        i = node[:cloud][:public_hostname]
      elsif config[:override_attribute]
        i = extract_nested_value(node, config[:override_attribute])
      else
        i = extract_nested_value(node, config[:attribute])
      end
      user = config[:ssh_user] || ssh_config[:user]
      hostspec = user ? "#{user}@#{i}" : node
    end
  end
end
