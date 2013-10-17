module Knife
  module Pkg
    class PlatformFamily
      class << self
        def map_to_pkg_ctrl(name)
          case name
          when 'debian'
            'apt'
          when 'rhel'
            'yum'
          else
            'unknown'
          end
        end
      end
    end
  end
end
