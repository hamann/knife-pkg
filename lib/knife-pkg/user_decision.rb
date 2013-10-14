require 'chef/knife'

module Knife
  module Pkg
    class UserDecision

      def self.ui
        @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
      end

      def self.yes?(text)
        decision = false
        while true
          response = ui.ask_question("#{text}", :default => false)
          case response
          when 'y'
            decision = true
            break
          when 'n'
            decision = false
            break
          end
        end
        decision
      end
    end
  end
end
