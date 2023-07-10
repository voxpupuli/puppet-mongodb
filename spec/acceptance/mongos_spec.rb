# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mongodb::mongos class' do
  case fact('osfamily')
  when 'Debian'
    package_name = if fact('os.distro.codename') =~ %r{^(buster|bullseye)$}
                     'mongodb-org-server'
                   else
                     'mongodb-server'
                   end
    config_file  = '/etc/mongodb-shard.conf'
  else
    package_name = 'mongodb-org-server'
    config_file  = '/etc/mongos.conf'
  end

  describe 'installation' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mongodb::server':
          configsvr => true,
          replset   => 'test',
          replset_members => ['127.0.0.1:27019'],
          port      => 27019,
        }
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
        class { 'mongodb::mongos':
          package_ensure => 'purged',
        }
        -> class { 'mongodb::server':
          ensure         => absent,
          package_ensure => absent,
          service_ensure => stopped,
          service_enable => false
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
