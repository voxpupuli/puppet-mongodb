# frozen_string_literal: true

require 'spec_helper'

describe 'mongodb::server' do
  shared_examples 'server classes' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_class('mongodb::server::install').
        that_comes_before('Class[mongodb::server::config]')
    }

    it {
      is_expected.to contain_class('mongodb::server::config').
        that_notifies('Class[mongodb::server::service]')
    }

    it { is_expected.to contain_class('mongodb::server::service') }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:config_file) do
        '/etc/mongod.conf'
      end

      let(:db_path) do
        if facts[:os]['family'] == 'RedHat'
          '/var/lib/mongo'
        else
          '/var/lib/mongodb'
        end
      end

      describe 'with defaults' do
        let(:log_path) do
          '/var/log/mongodb/mongod.log'
        end

        it_behaves_like 'server classes'
        it { is_expected.to contain_package('mongodb_server').with_ensure('present').with_name('mongodb-org-server').with_tag('mongodb_package') }

        it do
          is_expected.to contain_file(config_file).
            with_mode('0644').
            with_owner('root').
            with_group('root').
            with_content(%r{systemLog:\n\s*destination: file\n\s*logAppend: true\n\s*path: "#{log_path}"\n}m).
            with_content(%r{processManagement:\n\s*timeZoneInfo: "/usr/share/zoneinfo"\n}m).
            with_content(%r{net:\n\s*bindIp: 127\.0\.0\.1\n\s*port: 27017\n}m).
            with_content(%r{^storage\.dbPath: #{db_path}$}).
            without_content(%r{^storage\.journal\.enabled:})
        end

        it { is_expected.to contain_class('mongodb::repo') }

        it { is_expected.to contain_file('/root/.mongoshrc.js').with_ensure('file').without_content(%r{admin\.auth}) }
        it { is_expected.not_to contain_exec('fix dbpath permissions') }
      end

      describe 'with manage_package_repo => false' do
        let(:pre_condition) do
          'class { mongodb::globals:
          manage_package_repo => false
          }'
        end

        it_behaves_like 'server classes'
        it { is_expected.not_to contain_class('mongodb::repo') }
      end

      describe 'with create_admin => true' do
        let(:params) do
          {
            create_admin: true,
            admin_username: 'admin',
            admin_password: 'password'
          }
        end

        it_behaves_like 'server classes'

        it do
          is_expected.to contain_mongodb__db('admin').
            with_user('admin').
            with_password('password').
            with_roles(%w[userAdmin readWrite dbAdmin dbAdminAnyDatabase readAnyDatabase
                          readWriteAnyDatabase userAdminAnyDatabase clusterAdmin clusterManager
                          clusterMonitor hostManager root restore])
        end

        it { is_expected.to contain_mongodb_database('admin').that_requires('Service[mongodb]') }
      end

      describe 'with admin_password_hash => xxx89adfaxd' do
        let(:params) do
          {
            create_admin: true,
            admin_username: 'admin',
            admin_password_hash: 'xxx89adfaxd'
          }
        end

        it_behaves_like 'server classes'

        it do
          is_expected.to contain_mongodb__db('admin').
            with_user('admin').
            with_password_hash('xxx89adfaxd').
            with_roles(%w[userAdmin readWrite dbAdmin dbAdminAnyDatabase readAnyDatabase
                          readWriteAnyDatabase userAdminAnyDatabase clusterAdmin clusterManager
                          clusterMonitor hostManager root restore])
        end

        it { is_expected.to contain_mongodb_database('admin').that_requires('Service[mongodb]') }
      end

      describe 'with preset variables' do
        let :params do
          {
            config: '/etc/custom-mongod.conf'
          }
        end

        it { is_expected.to contain_file('/etc/custom-mongod.conf') }
      end

      describe 'with absent ensure' do
        let :params do
          {
            ensure: 'absent'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('mongodb::server::install') }
        it { is_expected.to contain_class('mongodb::server::config') }
        it { is_expected.to contain_class('mongodb::server::service') }
        it { is_expected.to contain_file(config_file).with_ensure('absent') }
      end

      describe 'with specific bind_ip values and ipv6' do
        let :params do
          {
            net_config: {
              'bindIp' => '127.0.0.1,fd00:beef:dead:55::143',
              'port' => 27_017,
              'ipv6' => true,
            }
          }
        end

        it do
          is_expected.to contain_file(config_file).
            with_content(%r{net:\n\s*bindIp: 127\.0\.0\.1,fd00:beef:dead:55::143\n\s*port: 27017\n\s*ipv6: true\n}m)
        end
      end

      describe 'with specific bind_ip values' do
        let :params do
          {
            net_config: {
              'bindIp' => '127.0.0.1,10.1.1.13',
              'port' => 27_017
            }
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{net:\n\s*bindIp: 127\.0\.0\.1,10\.1\.1\.13\n\s*port: 27017\n}m) }
      end

      describe 'when specifying set_parameter array value' do
        let :params do
          {
            set_parameter: ['textSearchEnable=true']
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^setParameter:\n  textSearchEnable=true}) }
      end

      describe 'when specifying set_parameter string value' do
        let :params do
          {
            set_parameter: 'textSearchEnable=true'
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^setParameter:\n  textSearchEnable=true}) }
      end

      describe 'with journal: true' do
        let :params do
          {
            journal: true
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^storage\.journal\.enabled: true$}) }
      end

      describe 'with journal: false' do
        let :params do
          {
            journal: false
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^storage\.journal\.enabled: false$}) }
      end

      describe 'with journal and package_version < 7.0.0' do
        let :params do
          {
            package_ensure: '6.0.0',
            journal: true
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^storage\.journal\.enabled: true$}) }
      end

      describe 'with journal and package_version >= 7.0.0' do
        let :params do
          {
            package_ensure: '7.0.0',
            journal: true
          }
        end

        it { is_expected.to raise_error(Puppet::Error) }
      end

      describe 'with journal and user defined repo_location without version' do
        let :params do
          {
            journal: true
          }
        end
        let(:pre_condition) do
          [
            'class mongodb::globals {
              $manage_package_repo = true
              $version = "5.0"
              $edition = "org"
              $repo_location = "https://repo.myorg.com/"
            }',
            'class{"mongodb::globals": }'
          ]
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^storage\.journal\.enabled: true$}) }
      end

      describe 'with journal and user defined repo_location with version < 7.0' do
        let :params do
          {
            journal: true
          }
        end
        let(:pre_condition) do
          [
            'class mongodb::globals {
              $manage_package_repo = true
              $version = "5.0"
              $edition = "org"
              $repo_location = "https://repo.myorg.com/6.0/"
            }',
            'class{"mongodb::globals": }'
          ]
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^storage\.journal\.enabled: true$}) }
      end

      describe 'with journal and user defined repo_location with version >= 7.0' do
        let :params do
          {
            journal: true
          }
        end
        let(:pre_condition) do
          [
            'class mongodb::globals {
              $manage_package_repo = true
              $version = "5.0"
              $edition = "org"
              $repo_location = "https://repo.myorg.com/7.0/"
            }',
            'class{"mongodb::globals": }'
          ]
        end

        it { is_expected.to raise_error(Puppet::Error) }
      end

      # check nested quota and quotafiles
      describe 'with quota to' do
        context 'true and without quotafiles' do
          let :params do
            {
              quota: true
            }
          end

          it { is_expected.to contain_file(config_file).with_content(%r{^storage\.quota\.enforced: true$}) }
        end

        context 'true and with quotafiles' do
          let :params do
            {
              quota: true,
              quotafiles: 1
            }
          end

          it {
            is_expected.to contain_file(config_file).
              with_content(%r{^storage\.quota\.enforced: true$}).
              with_content(%r{^storage\.quota\.maxFilesPerDB: 1$})
          }
        end
      end

      describe 'with store_creds' do
        context 'true' do
          let :params do
            {
              'security_config' => {
                'authorization' => 'enabled',
              },
              admin_username: 'admin',
              admin_password: 'password',
              store_creds: true
            }
          end

          it {
            is_expected.to contain_file('/root/.mongoshrc.js').
              with_ensure('file').
              with_owner('root').
              with_group('root').
              with_mode('0600').
              with_content(%r{admin\.auth\('admin', 'password'\)})
          }
        end

        context 'false' do
          let :params do
            {
              store_creds: false
            }
          end

          it { is_expected.to contain_file('/root/.mongoshrc.js').with_ensure('file').without_content(%r{admin\.auth}) }
        end
      end

      describe 'with dbpath_fix enabled' do
        let :params do
          {
            dbpath_fix: true,
            user: 'foo',
            group: 'bar'
          }
        end

        it do
          is_expected.to contain_exec('fix dbpath permissions').
            with_command("chown -R foo:bar #{db_path}").
            with_path(['/usr/bin', '/bin']).
            with_onlyif("find #{db_path} -not -user foo -o -not -group bar -print -quit | grep -q '.*'").
            that_subscribes_to("File[#{db_path}]")
        end
      end

      context 'when setting up replicasets' do
        describe 'should setup using replset_config' do
          let(:rsConf) do
            {
              'rsTest' => {
                'members' => [
                  'mongo1:27017',
                  'mongo2:27017',
                  'mongo3:27017'
                ],
                'arbiter' => 'mongo3:27017'
              }
            }
          end

          let(:params) do
            {
              replset: 'rsTest',
              replset_config: rsConf
            }
          end

          it { is_expected.to contain_class('mongodb::replset').with_sets(rsConf) }
        end

        describe 'should setup using replset_members' do
          let(:rsConf) do
            {
              'rsTest' => {
                'ensure' => 'present',
                'members' => [
                  'mongo1:27017',
                  'mongo2:27017',
                  'mongo3:27017'
                ]
              }
            }
          end

          let(:params) do
            {
              replset: 'rsTest',
              replset_members: [
                'mongo1:27017',
                'mongo2:27017',
                'mongo3:27017'
              ]
            }
          end

          it { is_expected.to contain_class('mongodb::replset').with_sets(rsConf) }
        end
      end
    end
  end

  context 'when deploying on Solaris' do
    let :facts do
      { osfamily: 'Solaris' }
    end

    it { is_expected.to raise_error(Puppet::Error) }
  end
end
