# frozen_string_literal: true

require 'spec_helper_acceptance'

repo_version = ENV.fetch('BEAKER_FACTER_mongodb_repo_version', nil)
repo_ver_param = "repo_version => '#{repo_version}'" if repo_version

describe 'mongodb::server class', if: supported_version?(default[:platform], repo_version) do
  config_file = '/etc/mongod.conf'
  service_name = 'mongod'
  package_name = 'mongodb-org-server'

  describe 'installation' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::server': }
        -> class { 'mongodb::client': }
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

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(27_017) do
      it { is_expected.to be_listening }
    end

    describe command('mongod --version') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  describe 'installation using custom port' do
    it 'change port to 27018' do
      pp = <<-EOS
        class { 'mongodb::globals':
        #{repo_ver_param}
      }
        -> class { 'mongodb::server':
          port => 27018,
        }
        -> class { 'mongodb::client': }
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

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(27_017) do
      it { is_expected.not_to be_listening }
    end

    describe port(27_018) do
      it { is_expected.to be_listening }
    end
  end

  describe 'installation using authentication' do
    after :all do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::server':
          ensure         => absent,
          package_ensure => purged,
          service_ensure => stopped
        }
        -> class { 'mongodb::client':
          ensure => purged
        }
      EOS

      apply_manifest(pp, catch_failures: true)
    end

    it 'works with no errors' do
      pp = <<-EOS
        class { 'mongodb::globals':
        #{repo_ver_param}
        }
        -> class { 'mongodb::server':
          auth           => true,
          create_admin   => false,
          handle_creds   => true,
          store_creds    => true,
          admin_username => 'admin',
          admin_password => 'password',
          restart        => true,
          set_parameter  => ['enableLocalhostAuthBypass: true']
        }
        -> class { 'mongodb::client': }

        mongodb_user { "User admin on db admin":
          ensure        => present,
          password_hash => mongodb_password('admin', 'password'),
          username      => 'admin',
          database      => 'admin',
          roles         => ['dbAdmin', 'userAdminAnyDatabase'],
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

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(27_017) do
      it { is_expected.to be_listening }
    end

    describe command('mongosh --quiet --eval "db.serverCmdLineOpts().ok"') do
      its(:stderr) { is_expected.to match %r{requires authentication} }
    end

    describe file('/root/.mongoshrc.js') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 600 }
      it { is_expected.to contain 'admin.auth(\'admin\', \'password\')' }
    end

    describe command("mongosh admin --quiet --eval \"load('/root/.mongoshrc.js');EJSON.stringify(db.getUser('admin')['customData'])\"") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match "{\"createdBy\":\"Puppet Mongodb_user['User admin on db admin']\"}\n" }
    end

    describe command('mongod --version') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  describe 'installation using authentication with complex password' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mongodb::globals':
        #{repo_ver_param}
        }
        -> class { 'mongodb::server':
          auth           => true,
          create_admin   => true,
          handle_creds   => true,
          store_creds    => true,
          admin_username => 'admin',
          admin_password => 'admin_\\\\_\\'_"_&_password',
          restart        => true,
        }
        class { 'mongodb::client': }
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

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(27_017) do
      it { is_expected.to be_listening }
    end

    describe command('mongosh --quiet --eval "db.serverCmdLineOpts().ok"') do
      its(:stderr) { is_expected.to match %r{requires authentication} }
    end

    describe file('/root/.mongoshrc.js') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 600 }
      it { is_expected.to contain 'admin.auth(\'admin\', \'admin_\\\\_\\\'_"_&_password\')' }
    end

    describe command("mongosh admin --quiet --eval \"load('/root/.mongoshrc.js');EJSON.stringify(db.getUser('admin')['customData'])\"") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match "{\"createdBy\":\"Puppet Mongodb_user['User admin on db admin']\"}\n" }
    end

    describe command('mongod --version') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  describe 'uninstallation' do
    it 'uninstalls mongodb' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::server':
            ensure => absent,
            package_ensure => purged,
            service_ensure => stopped,
            service_enable => false
          }
        -> class { 'mongodb::client': ensure => purged, }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(package_name) do
      it { is_expected.not_to be_installed }
    end

    describe service(service_name) do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end

    describe port(27_017) do
      it { is_expected.not_to be_listening }
    end

    describe port(27_018) do
      it { is_expected.not_to be_listening }
    end
  end
end
