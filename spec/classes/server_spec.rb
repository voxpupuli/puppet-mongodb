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

        it { is_expected.to contain_file(config_file).with_mode('0644').with_owner('root').with_group('root') }

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data).not_to have_key('processManagement')
          expect(config_data['systemLog']['destination']).to eql('file')
          expect(config_data['systemLog']['logAppend']).to be(true)
          expect(config_data['systemLog']['path']).to eql(log_path)
          expect(config_data['storage']['dbPath']).to eql(db_path)
          expect(config_data['storage']).not_to have_key('journal')
          expect(config_data['security']['authorization']).to eql('disabled')
          expect(config_data['net']['bindIp']).to eql('127.0.0.1')
          expect(config_data['net']).not_to have_key('ipv6')
        end

        it { is_expected.to contain_class('mongodb::repo') }
        it { is_expected.not_to contain_file(config_file).with_content(%r{fork}) }

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
            bind_ip: ['127.0.0.1', 'fd00:beef:dead:55::143'],
            ipv6: true
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['net']['bindIp']).to eql('127.0.0.1,fd00:beef:dead:55::143')
          expect(config_data['net']['ipv6']).to be(true)
        end
      end

      describe 'with specific bind_ip values' do
        let :params do
          {
            bind_ip: ['127.0.0.1', '10.1.1.13']
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['net']['bindIp']).to eql('127.0.0.1,10.1.1.13')
        end
      end

      describe 'when specifying auth to true' do
        let :params do
          {
            auth: true
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['security']['authorization']).to eql('enabled')
        end

        it { is_expected.to contain_file('/root/.mongoshrc.js') }
      end

      describe 'when specifying set_parameter array value with : separator' do
        let :params do
          {
            set_parameter: [
              'textSearchEnable: true',
              'authenticationMechanisms: PLAIN'
            ]
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['setParameter']['textSearchEnable']).to be(true)
          expect(config_data['setParameter']['authenticationMechanisms']).to eql('PLAIN')
        end
      end

      describe 'when specifying set_parameter string value with : separator' do
        let :params do
          {
            set_parameter: 'textSearchEnable: true'
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['setParameter']['textSearchEnable']).to be(true)
        end
      end

      describe 'when specifying set_parameter array value with = separator' do
        let :params do
          {
            set_parameter: [
              'textSearchEnable = true',
              'authenticationMechanisms = PLAIN'
            ]
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['setParameter']['textSearchEnable']).to be(true)
          expect(config_data['setParameter']['authenticationMechanisms']).to eql('PLAIN')
        end
      end

      describe 'when specifying set_parameter string value with = separator' do
        let :params do
          {
            set_parameter: 'textSearchEnable = true'
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['setParameter']['textSearchEnable']).to be(true)
        end
      end

      describe 'when specifying set_parameter hash value' do
        let :params do
          {
            set_parameter: {
              'textSearchEnable' => true,
              'authenticationMechanisms' => 'PLAIN',
            }
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['setParameter']['textSearchEnable']).to be(true)
          expect(config_data['setParameter']['authenticationMechanisms']).to eql('PLAIN')
        end
      end

      describe 'with journal: true' do
        let :params do
          {
            journal: true
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['storage']['journal']['enabled']).to be(true)
        end
      end

      describe 'with journal: false' do
        let :params do
          {
            journal: false
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['storage']['journal']['enabled']).to be(false)
        end
      end

      describe 'with journal and package_version < 7.0.0' do
        let :params do
          {
            package_ensure: '6.0.0',
            journal: true
          }
        end

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['storage']['journal']['enabled']).to be(true)
        end
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

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['storage']['journal']['enabled']).to be(true)
        end
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

        it do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['storage']['journal']['enabled']).to be(true)
        end
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

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['storage']['quota']['enforced']).to be(true)
            expect(config_data['storage']['quota']).not_to have_key('maxFilesPerDB')
          end
        end

        context 'true and with quotafiles' do
          let :params do
            {
              quota: true,
              quotafiles: 1
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['storage']['quota']['enforced']).to be(true)
            expect(config_data['storage']['quota']['maxFilesPerDB']).to be(1)
          end
        end
      end

      describe 'when specifying syslog value' do
        context 'it should be set to true' do
          let :params do
            {
              syslog: true,
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['systemLog']['destination']).to eql('syslog')
          end
        end
      end

      describe 'with store_creds' do
        context 'true' do
          let :params do
            {
              admin_username: 'admin',
              admin_password: 'password',
              auth: true,
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

          context 'with complex password' do
            let :params do
              {
                admin_username: 'admin',
                admin_password: 'complex_\\_\'_"_&_password',
                auth: true,
                store_creds: true
              }
            end

            it {
              is_expected.to contain_file('/root/.mongoshrc.js').
                with_content(%r{admin\.auth\('admin', 'complex_\\\\_\\'_"_&_password'\)})
            }
          end
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

      describe 'with custom pidfilemode' do
        let :params do
          {
            manage_pidfile: true,
            pidfilepath: '/var/run/mongodb/mongod.pid',
            pidfilemode: '0640'
          }
        end

        it { is_expected.to contain_file('/var/run/mongodb/mongod.pid').with_mode('0640') }
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

      describe 'with tls' do
        context 'enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem'
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
          end
        end

        context 'disabled' do
          let :params do
            {
              tls: false
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']).not_to have_key('tls')
          end
        end
      end

      describe 'with tls and client certificate validation' do
        context 'enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem',
              tls_ca: '/etc/ssl/caToValidateClientCertificates.pem'
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
            expect(config_data['net']['tls']['CAFile']).to eql('/etc/ssl/caToValidateClientCertificates.pem')
          end
        end

        context 'client certificate validation disabled but tls enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem'
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
            expect(config_data['net']['tls']).not_to have_key('CAFile')
          end
        end
      end

      describe 'with tls, client certificate validation and allow connection without certificates' do
        context 'enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem',
              tls_ca: '/etc/ssl/caToValidateClientCertificates.pem',
              tls_conn_without_cert: true
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
            expect(config_data['net']['tls']['CAFile']).to eql('/etc/ssl/caToValidateClientCertificates.pem')
            expect(config_data['net']['tls']['allowConnectionsWithoutCertificates']).to be(true)
          end
        end

        context 'connection without certificates disabled but tls and client certificate validation enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem',
              tls_ca: '/etc/ssl/caToValidateClientCertificates.pem',
              tls_conn_without_cert: false
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
            expect(config_data['net']['tls']['CAFile']).to eql('/etc/ssl/caToValidateClientCertificates.pem')
            expect(config_data['net']['tls']['allowConnectionsWithoutCertificates']).to be(false)
          end
        end
      end

      describe 'with tls and allow invalid hostnames' do
        context 'enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem',
              tls_invalid_hostnames: true
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
            expect(config_data['net']['tls']['allowInvalidHostnames']).to be(true)
          end
        end

        context 'disallow invalid hostnames but tls enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem',
              tls_invalid_hostnames: false
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
            expect(config_data['net']['tls']['allowInvalidHostnames']).to be(false)
          end
        end
      end

      describe 'with tls and allow invalid certificates' do
        context 'enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem',
              tls_invalid_certificates: true
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
            expect(config_data['net']['tls']['allowInvalidCertificates']).to be(true)
          end
        end

        context 'disallow invalid certificates but tls enabled' do
          let :params do
            {
              tls: true,
              tls_mode: 'requireTLS',
              tls_key: '/etc/ssl/mongodb.pem',
              tls_invalid_certificates: false
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['tls']['mode']).to eql('requireTLS')
            expect(config_data['net']['tls']['certificateKeyFile']).to eql('/etc/ssl/mongodb.pem')
            expect(config_data['net']['tls']['allowInvalidCertificates']).to be(false)
          end
        end

        context 'disabled' do
          let :params do
            {
              tls: false
            }
          end

          it { is_expected.not_to contain_file(config_file).with_content(%r{net\.tls\.allowInvalidHostnames:\s*true}) }
        end
      end

      context 'setting nohttpinterface' do
        it "isn't set when undef" do
          config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
          expect(config_data['net']).not_to have_key('http')
        end

        describe 'sets net.http.enabled to false when true' do
          let(:params) do
            { nohttpinterface: true }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['http']['enabled']).to be(false)
          end
        end

        describe 'sets net.http.enabled to true when false' do
          let(:params) do
            { nohttpinterface: false }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['net']['http']['enabled']).to be(true)
          end
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

      describe 'with config_data' do
        context 'without other params' do
          let :params do
            {
              config_data: {
                'auditLog' => {
                  'destination' => 'file',
                  'format' => 'JSON',
                  'path' => '/var/log/mobgodb/audit.log',
                },
              },
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['auditLog']['destination']).to eql('file')
            expect(config_data['auditLog']['format']).to eql('JSON')
            expect(config_data['auditLog']['path']).to eql('/var/log/mobgodb/audit.log')
          end
        end

        context 'with other params' do
          let :params do
            {
              auth: true,
              config_data: {
                'security' => {
                  'javascriptEnabled' => false,
                },
              },
            }
          end

          it do
            config_data = YAML.safe_load(catalogue.resource("File[#{config_file}]")[:content])
            expect(config_data['security']['authorization']).to eql('enabled')
            expect(config_data['security']['javascriptEnabled']).to be(false)
          end
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
