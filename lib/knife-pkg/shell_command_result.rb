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
