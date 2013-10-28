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
    class ShellCommand

      def self.exec(cmd, session, password = '')

        stdout_data, stderr_data = "", ""
        exit_code, exit_signal = nil, nil
        session.open_channel do |channel|
          channel.request_pty
          channel.exec(cmd) do |_, success|
            raise RuntimeError, "Command \"#{@cmd}\" could not be executed!" if !success
            channel.on_data do |_, data|
              if data =~ /^knife sudo password: /
                Chef::Log.debug("sudo password required, sending password")
                if password.respond_to?(:call)
                  channel.send_data(password.call + "\n")
                else
                  channel.send_data(password + "\n")
                end
              else
                stdout_data += data
              end
            end

            channel.on_extended_data do |_,_,data|
              stderr_data += data
            end

            channel.on_request("exit-status") do |_,data|
              exit_code = data.read_long
            end

            channel.on_request("exit-signal") do |_, data|
              exit_signal = data.read_long
            end
          end
        end
        session.loop

        result = ShellCommandResult.new(cmd, stdout_data, stderr_data, exit_code.to_i)

        raise_error!(result) unless result.succeeded?

        return result
      end

      def self.raise_error!(result)
        raise RuntimeError, "Command failed! #{result.to_s}" 
      end

    end
  end
end
