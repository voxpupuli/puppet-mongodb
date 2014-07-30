require 'spec_helper'

describe 'mongodb::server::install', :type => :class do

  shared_context 'defaults' do |package_name|
    let(:pre_condition) { 'include mongodb::server' }
    include_context 'without_managed_repo'

    it {
      should contain_package(package_name).with({
        :ensure   => 'present',
      }).without_require
    }

  end

  shared_context 'with_custom_params' do
    let(:pre_condition) { [
      "class mongodb::server { $package_ensure = true $package_name = 'custom_package_name' $dbpath = '/var/lib/mongo' $user = 'mongodb' }",
      "include mongodb::server"
    ]}

    it {
      should contain_package('custom_package_name').with({
        :ensure   => 'present',
      }).without_require
    }
  end

  shared_context 'with_managed_repo' do |package_name|
    let(:pre_condition) { [
      "class mongodb::globals { $manage_package_repo = true }",
      "include mongodb::globals",
      "include mongodb::server"
    ]}

    it { should contain_class('mongodb::repo') }

    it {
      should contain_package(package_name).with({
        :ensure   => 'present',
        :require  => "Anchor[mongodb::repo::end]",
      })
    }
  end

  shared_context 'with_managed_repo_with_version' do |package_name|
    let(:pre_condition) { [
      "class mongodb::globals { $manage_package_repo = true $version = '1.2.3.4' }",
      "include mongodb::globals",
      "include mongodb::server",
    ]}

    it { should contain_class('mongodb::repo') }

    it {
      should contain_package(package_name).with({
        :ensure   => '1.2.3.4',
        :require  => "Anchor[mongodb::repo::end]",
      })
    }
  end

  shared_context 'with_unmanaged_repo_with_version' do |package_name|
    let(:pre_condition) { [
      "class mongodb::globals { $version = '1.2.3.4' }",
      "include mongodb::globals",
      "include mongodb::server"
    ]}

    include_context 'without_managed_repo'

    it {
      should contain_package(package_name).with({
        :ensure   => '1.2.3.4',
      }).without_require
    }
  end

  shared_context 'without_managed_repo' do
    it { should_not contain_class('mongodb::repo') }
  end


  context 'when deploying on RedHat' do
    let (:facts) { { :osfamily => 'RedHat' } }

    context 'using defaults' do
      include_context 'defaults', 'mongodb-server'
    end

    context 'using custom params' do
      include_context 'with_custom_params'
      include_context 'without_managed_repo'
    end

    context 'using managed repo' do
      include_context 'with_managed_repo', 'mongodb-org-server'
    end

    context 'using version' do
      context 'using managed repo' do
        include_context 'with_managed_repo_with_version', 'mongodb-org-server'
      end

      context 'using unmanaged repo' do
        include_context 'with_unmanaged_repo_with_version', 'mongodb-server'
      end
    end
  end

  context 'when deploying on Debian' do
    let (:facts) { {
        :osfamily => 'Debian',
        :lsbdistid  => 'Debian' # rquired for apt
    }}

    context 'using defaults' do
      include_context 'defaults', 'mongodb-server'
    end

    context 'using custom params' do
      include_context 'with_custom_params'
      include_context 'without_managed_repo'
    end

    context 'using managed repo' do
      include_context 'with_managed_repo', 'mongodb-org-server'
    end

    context 'using version' do
      context 'using managed repo' do
        include_context 'with_managed_repo_with_version', 'mongodb-org-server'
      end

      context 'using unmanaged repo' do
        include_context 'with_unmanaged_repo_with_version', 'mongodb-server'
      end
    end
  end

end
