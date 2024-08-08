# frozen_string_literal: true
#-------------------------------------------------------------------------
# # Copyright (c) Microsoft and contributors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------
require 'test_helper'
require 'azure/core'
require 'pry'
describe 'Azure core service' do
  let(:core_service) { Azure::Core::Service.new(host) }

  let(:host) { 'http://dumyhost.uri' }

  describe '#generate_uri' do
    describe 'with no args' do
      subject { core_service.generate_uri }

      it { _(subject).must_be_kind_of ::URI }
      it { _(subject.to_s).must_equal 'http://dumyhost.uri/' }
    end

    describe 'with nonempty path' do
      subject { core_service.generate_uri(path) }

      let(:path) { 'resource/entity/' }

      it 'sets path on the uri' do
        _(subject.path).must_equal '/resource/entity/'
      end

      describe 'when host has a path' do
        let(:host) { 'http://dummyhost.uri/host/path' }

        it 'generate_uri should correctly join the path if host url contained a path' do
          _(subject.path).must_equal '/host/path/resource/entity/'
        end
      end

      describe 'when path contains encoded values' do
        describe 'when it has encoded spaces' do
          let(:path) { 'blob%20name%20with%20spaces' }

          it { _(subject.host).must_equal 'dumyhost.uri'}

          it 'does not re-encode path with spaces' do
            _(subject.path).must_equal "/#{path}"
          end
        end

        describe 'when it has encoded characters' do
          let(:path) { 'host/path/%D1%84%D0%B1%D0%B0%D1%84.jpg' }

          it { _(subject.host).must_equal 'dumyhost.uri'}

          it 'generate_uri should not re-encode path with special characters' do
            _(subject.path).must_equal "/#{path}"
          end
        end
      end

      describe 'with options' do
        subject { core_service.generate_uri('', options) }

        let(:options) { {'key' => 'value !', 'key !' => 'value', 'timeout' => 45 } }

        it 'encodes keys and values' do
          _(subject.query).must_include 'key=value+%21&key+%21=value&timeout=45'
        end
      end
    end
  end
end
