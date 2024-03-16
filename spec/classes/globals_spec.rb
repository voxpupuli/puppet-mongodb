# frozen_string_literal: true

require 'spec_helper'

describe 'mongodb::globals' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to contain_class('mongodb::repo') }

      context 'with manage_package_repo at false' do
        let(:params) do
          { manage_package_repo: false }
        end

        it { is_expected.not_to contain_class('mongodb::repo') }
      end
    end
  end
end
