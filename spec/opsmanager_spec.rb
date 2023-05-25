# frozen_string_literal: true

require 'spec_helper'

describe 'mongodb::opsmanager' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) do
        {
          opsmanager_url: 'http://localhost:8080'
        }
      end

      describe 'with defaults' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_service('mongodb') }

        it do
          is_expected.to create_package('mongodb-mms').
            with_ensure('present')
        end

        it do
          is_expected.to contain_file('/opt/mongodb/mms/conf/conf-mms.properties').
            with_ensure('file').
            that_requires('Package[mongodb-mms]')
        end

        it do
          is_expected.to contain_service('mongodb-mms').
            that_subscribes_to(['Package[mongodb-mms]', 'File[/opt/mongodb/mms/conf/conf-mms.properties]'])
        end
      end
    end
  end
end
