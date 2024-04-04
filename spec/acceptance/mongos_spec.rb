# frozen_string_literal: true

require 'spec_helper_acceptance'

repo_version = ENV.fetch('BEAKER_FACTER_mongodb_repo_version', nil)
repo_ver_param = "repo_version => '#{repo_version}'" if repo_version

describe 'mongodb::mongos class', if: supported_version?(default[:platform], repo_version) do
  package_name = 'mongodb-org-server'
  config_file = '/etc/mongos.conf'

  describe 'installation' do
    it 'works with no errors' do
      pp = <<-EOS
          class { 'mongodb::globals':
            #{repo_ver_param}
          }
          -> class { 'mongodb::server':
          configsvr => true,
          replset   => 'test',
          replset_members => ['127.0.0.1:27019'],
          port      => 27019,
        }
        -> class { 'mongodb::client': }
        -> class { 'mongodb::mongos':
          configdb => ['test/127.0.0.1:27019'],
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(package_name) do
      it { is_expected.to be_installed }
    end

    describe file(config_file) do
      it { is_expected.to be_file }
    end

    describe service('mongos') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(27_017) do
      it { is_expected.to be_listening }
    end

    describe port(27_019) do
      it { is_expected.to be_listening }
    end

    describe command('mongod --version') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  describe 'uninstalling' do
    it 'uninstalls mongodb' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::mongos':
          package_ensure => 'purged',
        }
        -> class { 'mongodb::server':
          ensure         => absent,
          package_ensure => purged,
          service_ensure => stopped,
          service_enable => false
        }
        -> class { 'mongodb::client':
          ensure => purged,
        }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(package_name) do
      it { is_expected.not_to be_installed }
    end

    describe service('mongos') do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end

    describe port(27_017) do
      it { is_expected.not_to be_listening }
    end

    describe port(27_019) do
      it { is_expected.not_to be_listening }
    end
  end
end
