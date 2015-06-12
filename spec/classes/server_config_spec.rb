require 'spec_helper'

describe 'mongodb::server::config', :type => :class do

  describe 'with preseted variables' do
    let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' }", "include mongodb::server"]}

    it {
      is_expected.to contain_file('/etc/mongod.conf')
    }

  end

  describe 'with default values' do
    let(:pre_condition) {[ "class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $user = 'mongod' $group = 'mongod' $port = 29017 $bind_ip = ['0.0.0.0'] $fork = true $logpath ='/var/log/mongo/mongod.log' $logappend = true }",  "include mongodb::server" ]}

    it {
      is_expected.to contain_file('/etc/mongod.conf').with({
        :mode   => '0644',
        :owner  => 'root',
        :group  => 'root'
      })

      is_expected.to contain_file('/etc/mongod.conf').with_content(/^dbpath=\/var\/lib\/mongo/)
      is_expected.to contain_file('/etc/mongod.conf').with_content(/bind_ip\s=\s0\.0\.0\.0/)
      is_expected.to contain_file('/etc/mongod.conf').with_content(/^port = 29017$/)
      is_expected.to contain_file('/etc/mongod.conf').with_content(/^logappend=true/)
      is_expected.to contain_file('/etc/mongod.conf').with_content(/^logpath=\/var\/log\/mongo\/mongod\.log/)
      is_expected.to contain_file('/etc/mongod.conf').with_content(/^fork=true/)
    }
  end

  describe 'with absent ensure' do
    let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = absent }", "include mongodb::server"]}

    it {
      is_expected.to contain_file('/etc/mongod.conf').with({ :ensure => 'absent' })
    }

  end

  describe 'when specifying storage_engine' do
    let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $version='3.0.3' $storage_engine = 'SomeEngine' $storage_engine_internal = 'SomeEngine' $user = 'mongod' $group = 'mongod' $port = 29017 $bind_ip = ['0.0.0.0'] $fork = true $logpath ='/var/log/mongo/mongod.log' $logappend = true}", "include mongodb::server"]}

    it {
      is_expected.to contain_file('/etc/mongod.conf').with_content(/storage.engine:\sSomeEngine/)
    }
  end

  describe 'with specific bind_ip values and ipv6' do
    let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $bind_ip = ['127.0.0.1', 'fd00:beef:dead:55::143'] $ipv6 = true }", "include mongodb::server"]}

    it {
      is_expected.to contain_file('/etc/mongod.conf').with_content(/bind_ip\s=\s127\.0\.0\.1\,fd00:beef:dead:55::143/)
      is_expected.to contain_file('/etc/mongod.conf').with_content(/ipv6=true/)
    }
  end

  describe 'with specific bind_ip values' do
    let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $bind_ip = ['127.0.0.1', '10.1.1.13']}", "include mongodb::server"]}

    it {
      is_expected.to contain_file('/etc/mongod.conf').with_content(/bind_ip\s=\s127\.0\.0\.1\,10\.1\.1\.13/)
    }
  end

  describe 'when specifying auth to true' do
    let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $auth = true $dbpath = '/var/lib/mongo' $ensure = present }", "include mongodb::server"]}

    it {
      is_expected.to contain_file('/etc/mongod.conf').with_content(/^auth=true/)
    }
  end
  
  describe 'when specifying set_parameter value' do
    let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $set_parameter = 'textSearchEnable=true' $dbpath = '/var/lib/mongo' $ensure = present }", "include mongodb::server"]}

    it {
      is_expected.to contain_file('/etc/mongod.conf').with_content(/^setParameter = textSearchEnable=true/)
    }
  end

  describe 'with journal:' do
    context 'on true with i686 architecture' do
      let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $journal = true }", "include mongodb::server"]}
      let (:facts) { { :architecture => 'i686' } }

      it {
        is_expected.to contain_file('/etc/mongod.conf').with_content(/^journal = true/)
      }
    end
  end

  # check nested quota and quotafiles
  describe 'with quota to' do

    context 'true and without quotafiles' do
      let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $quota = true }", "include mongodb::server"]}
      it {
        is_expected.to contain_file('/etc/mongod.conf').with_content(/^quota = true/)
      }
    end

    context 'true and with quotafiles' do
      let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $quota = true $quotafiles = 1 }", "include mongodb::server"]}

      it {
        is_expected.to contain_file('/etc/mongod.conf').with_content(/quota = true/)
        is_expected.to contain_file('/etc/mongod.conf').with_content(/quotaFiles = 1/)
      }
    end
  end

  describe 'when specifying syslog value' do
    context 'it should be set to true' do
      let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $syslog = true }", "include mongodb::server"]}

      it {
        is_expected.to contain_file('/etc/mongod.conf').with_content(/^syslog = true/)
      }
    end

    context 'if logpath is also set an error should be raised' do
      let(:pre_condition) { ["class mongodb::server { $config = '/etc/mongod.conf' $dbpath = '/var/lib/mongo' $ensure = present $syslog = true $logpath ='/var/log/mongo/mongod.log' }", "include mongodb::server"]}

      it {
        expect { is_expected.to contain_file('/etc/mongod.conf') }.to raise_error(Puppet::Error, /You cannot use syslog with logpath/)
      }
    end

  end

end
