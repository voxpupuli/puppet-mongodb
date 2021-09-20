require 'spec_helper'

describe 'mongodb::mongos' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      case facts[:os]['family']
      when 'Debian'
        package_name = if facts[:os]['release']['major'] =~ %r{(10)}
                         'mongodb-org-mongos'
                       else
                         'mongodb-server'
                       end
        config_file  = '/etc/mongodb-shard.conf'
      else
        package_name = 'mongodb-org-mongos'
        config_file  = '/etc/mongos.conf'
      end

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }

        # install
        it { is_expected.to contain_class('mongodb::mongos::install') }
        if facts[:os]['release']['major'] =~ %r{(10)}
          it { is_expected.to contain_package('mongodb_mongos').with_ensure('4.4.8').with_name(package_name).with_tag('mongodb_package') }
        else
          it { is_expected.to contain_package('mongodb_mongos').with_ensure('present').with_name(package_name).with_tag('mongodb_package') }
        end

        # config
        it { is_expected.to contain_class('mongodb::mongos::config') }

        case facts[:osfamily]
        when 'RedHat', 'Suse'
          expected_content = <<-CONFIG
configdb = 127.0.0.1:27019
fork = true
pidfilepath = /var/run/mongodb/mongos.pid
logpath = /var/log/mongodb/mongos.log
unixSocketPrefix = /var/run/mongodb
          CONFIG

          it { is_expected.to contain_file('/etc/mongos.conf').with_content(expected_content) }
        when 'Debian'
          expected_content = <<-CONFIG
configdb = 127.0.0.1:27019
          CONFIG

          it { is_expected.to contain_file('/etc/mongodb-shard.conf').with_content(expected_content) }
        end

        # service
        it { is_expected.to contain_class('mongodb::mongos::service') }

        if facts[:osfamily] == 'RedHat' || facts[:osfamily] == 'Suse'
          it { is_expected.to contain_file('/etc/sysconfig/mongos') }
        else
          it { is_expected.not_to contain_file('/etc/sysconfig/mongos') }
        end

        if facts[:osfamily] == 'Debian'
          it { is_expected.to contain_file('/etc/init.d/mongos') }
        else
          it { is_expected.not_to contain_file('/etc/init.d/mongos') }
        end

        it { is_expected.to contain_service('mongos') }
      end

      describe 'with specific bind_ip values' do
        let :params do
          {
            bind_ip: ['127.0.0.1', '10.1.1.13']
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^bind_ip = 127\.0\.0\.1\,10\.1\.1\.13$}) }
      end

      context 'package_name => mongo-foo' do
        let(:params) do
          {
            package_name: 'mongo-foo'
          }
        end

        it { is_expected.to compile.with_all_deps }

        if facts[:os]['release']['major'] =~ %r{(10)}
          it { is_expected.to contain_package('mongodb_mongos').with_name('mongo-foo').with_ensure('4.4.8').with_tag('mongodb_package') }
        else
          it { is_expected.to contain_package('mongodb_mongos').with_name('mongo-foo').with_ensure('present').with_tag('mongodb_package') }
        end
      end

      context 'service_manage => false' do
        let(:params) do
          {
            service_manage: false
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_file('/etc/sysconfig/mongos') }
        it { is_expected.not_to contain_file('/etc/init.d/mongos') }
        it { is_expected.not_to contain_service('mongos') }
      end

      context 'package_ensure => purged' do
        let(:params) do
          {
            package_ensure: 'purged'
          }
        end

        it { is_expected.to compile.with_all_deps }

        # install
        it { is_expected.to contain_class('mongodb::mongos::install') }
        if facts[:osfamily] == 'Suse'
          it { is_expected.to contain_package('mongodb_mongos').with_ensure('absent') }
        else
          it { is_expected.to contain_package('mongodb_mongos').with_ensure('purged') }
        end

        # config
        it { is_expected.to contain_class('mongodb::mongos::config') }

        case facts[:osfamily]
        when 'RedHat', 'Suse'
          it { is_expected.to contain_file('/etc/mongos.conf').with_ensure('absent') }
        when 'Debian'
          it { is_expected.to contain_file('/etc/mongodb-shard.conf').with_ensure('absent') }
        end

        if facts[:osfamily] == 'RedHat' || facts[:osfamily] == 'Suse'
          it { is_expected.to contain_file('/etc/sysconfig/mongos').with_ensure('absent') }
        else
          it { is_expected.not_to contain_file('/etc/sysconfig/mongos') }
        end

        if facts[:osfamily] == 'Debian'
          it { is_expected.to contain_file('/etc/init.d/mongos').with_ensure('absent') }
        else
          it { is_expected.not_to contain_file('/etc/init.d/mongos') }
        end

        # service
        it { is_expected.to contain_class('mongodb::mongos::service') }

        it { is_expected.to contain_service('mongos').with_ensure('stopped').with_enable(false) }
      end
    end
  end

  context 'when deploying on Solaris' do
    let :facts do
      { osfamily: 'Solaris' }
    end

    it { is_expected.to compile.and_raise_error(%r{is not applicable to an Undef Value}) }
  end
end
