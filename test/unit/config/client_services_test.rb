#-------------------------------------------------------------------------
# # Copyright (c) Microsoft and contributors. All rights reserved.
#
# The MIT License(MIT)

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files(the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions :

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#--------------------------------------------------------------------------
require "unit/test_helper"
require "azure/storage/common"

describe Azure::Storage::Common::Client do
  describe '.create' do
    subject { Azure::Storage::Common::Client.create(params) }

    let(:azure_storage_account) { "testStorageAccount" }
    let(:azure_storage_access_key) { "testKey1" }
    let(:storage_sas_token) { "testSAS1" }

    describe 'with :storage_account_name' do
      describe 'with :storage_access_key' do
        let(:params) {
          {
            storage_account_name: azure_storage_account,
            storage_access_key: azure_storage_access_key
          }
        }

        it "storage host should be set to default" do
          _(subject.storage_account_name).must_equal azure_storage_account
          _(subject.storage_access_key).must_equal azure_storage_access_key
          _(subject.storage_blob_host).must_equal "https://#{azure_storage_account}.blob.core.windows.net"
          _(subject.storage_blob_host(true)).must_equal "https://#{azure_storage_account}-secondary.blob.core.windows.net"
          _(subject.storage_table_host).must_equal "https://#{azure_storage_account}.table.core.windows.net"
          _(subject.storage_table_host(true)).must_equal "https://#{azure_storage_account}-secondary.table.core.windows.net"
          _(subject.storage_queue_host).must_equal "https://#{azure_storage_account}.queue.core.windows.net"
          _(subject.storage_queue_host(true)).must_equal "https://#{azure_storage_account}-secondary.queue.core.windows.net"
          _(subject.storage_file_host).must_equal "https://#{azure_storage_account}.file.core.windows.net"
          _(subject.storage_file_host(true)).must_equal "https://#{azure_storage_account}-secondary.file.core.windows.net"
          assert_nil(subject.signer)
        end
      end
    end

    describe 'with :storage_sas' do
      let(:params) {
        {
          storage_account_name: azure_storage_account,
          storage_sas_token: storage_sas_token
        }
      }

      it { _(subject.storage_account_name).must_equal azure_storage_account }
      it { _(subject.storage_sas_token).must_equal storage_sas_token }
      it { _(subject.storage_blob_host).must_equal "https://#{azure_storage_account}.blob.core.windows.net" }
      it { _(subject.storage_blob_host(true)).must_equal "https://#{azure_storage_account}-secondary.blob.core.windows.net" }
      it {  _(subject.storage_table_host).must_equal "https://#{azure_storage_account}.table.core.windows.net" }
      it { _(subject.storage_table_host(true)).must_equal "https://#{azure_storage_account}-secondary.table.core.windows.net" }
      it { _(subject.storage_queue_host).must_equal "https://#{azure_storage_account}.queue.core.windows.net" }
      it { _(subject.storage_queue_host(true)).must_equal "https://#{azure_storage_account}-secondary.queue.core.windows.net" }
      it { _(subject.storage_file_host).must_equal "https://#{azure_storage_account}.file.core.windows.net" }
      it { _(subject.storage_file_host(true)).must_equal "https://#{azure_storage_account}-secondary.file.core.windows.net" }
      it { _(subject.signer).wont_be_nil }
      it { _(subject.signer.class).must_equal Azure::Storage::Common::Core::Auth::SharedAccessSignatureSigner }
    end

    describe '.create_development' do
      subject { Azure::Storage::Common::Client.create_development }

      let(:proxy_uri) {
        Azure::Storage::Common::StorageServiceClientConstants::DEV_STORE_URI
      }

      it { _(subject.storage_account_name).must_equal Azure::Storage::Common::StorageServiceClientConstants::DEVSTORE_STORAGE_ACCOUNT }
      it { _(subject.storage_access_key).must_equal Azure::Storage::Common::StorageServiceClientConstants::DEVSTORE_STORAGE_ACCESS_KEY }
      it { _(subject.storage_blob_host).must_equal "#{proxy_uri}:#{Azure::Storage::Common::StorageServiceClientConstants::DEVSTORE_BLOB_HOST_PORT}" }
      it { _(subject.storage_table_host).must_equal "#{proxy_uri}:#{Azure::Storage::Common::StorageServiceClientConstants::DEVSTORE_TABLE_HOST_PORT}" }
      it { _(subject.storage_queue_host).must_equal "#{proxy_uri}:#{Azure::Storage::Common::StorageServiceClientConstants::DEVSTORE_QUEUE_HOST_PORT}" }
      it { _(subject.storage_file_host).must_equal "#{proxy_uri}:#{Azure::Storage::Common::StorageServiceClientConstants::DEVSTORE_FILE_HOST_PORT}" }
      it { assert_nil(subject.signer)}
    end

    describe '.create_from_env' do
      subject {
        Azure::Storage::Common::Client.create_from_env do |opt|
          opt[:storage_sas_token] = 'storage_sas_token'
        end
      }

      let(:connection_string_client) {
        Azure::Storage::Common::Client.create_from_connection_string(ENV['AZURE_STORAGE_CONNECTION_STRING'])
      }
      # FIXME: Figure out valid conn string structure; appearsto be false pass on mathching nil sas_token
      # let(:azure_storage_connection_string) {
      #   [
      #     "DefaultEndpointsProtocol=https",
      #     "AccountName=myAccountName",
      #     "StorageAccessKey=storage_sas_token"
      #   ].join(";\n")
      #   'storage_sas_token'
      #  }

      it { _(subject.storage_account_name).must_equal connection_string_client.storage_account_name }
      it { _(subject.storage_access_key).must_equal connection_string_client.storage_access_key  }
      it { _(subject.storage_sas_token).must_equal connection_string_client.storage_sas_token }
      it { _(subject.storage_blob_host).must_equal connection_string_client.storage_blob_host }
      it { _(subject.storage_table_host).must_equal connection_string_client.storage_table_host }
      it { _(subject.storage_queue_host).must_equal connection_string_client.storage_queue_host }
      it { _(subject.storage_file_host).must_equal connection_string_client.storage_file_host }
    end
  end
end
