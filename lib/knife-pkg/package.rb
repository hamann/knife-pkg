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
    class Package
      attr_accessor :name, :version

      def initialize(name, version = '0.0')
        @name = name.strip
        @version = version
      end

      def to_s
        @name + (version_to_s == '' ? '' : " #{version_to_s}")
      end

      def version_to_s
        if @version.to_s != '0.0'
          "(#{@version})"
        else
          ''
        end
      end
    end
  end
end
