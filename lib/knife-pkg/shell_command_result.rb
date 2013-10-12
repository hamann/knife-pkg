module Knife
  module Pkg
    class ShellCommandResult

      attr_accessor :cmd
      attr_accessor :stdout
      attr_accessor :stderr
      attr_accessor :exit_code

      def initialize(cmd, stdout, stderr, exit_code)
        @cmd = cmd
        @stdout = stdout
        @stderr = stderr
        @exit_code = exit_code
      end

      def to_s
        return "Command: \"#{@cmd}\", stdout: \"#{@stdout}\", stderr: \"#{@stderr}\", exit_code: \"#{@exit_code}\""
      end

      def succeeded?
        return @exit_code.to_i == 0 ? true : false
      end

    end
  end
end
