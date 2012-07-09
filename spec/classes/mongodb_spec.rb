require 'spec_helper'

describe 'mongodb', :type => :class do

  describe 'when deploying on debian' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :lsbdistcodename => 'sid',
      }
    end

    it {
      should contain_class('mongodb::sources::apt')
      should contain_package('mongodb-10gen').with({
        :name => 'mongodb-10gen'
      })
      should contain_file('/etc/mongod.conf')
      should contain_service('mongodb').with({
        :name => 'mongodb'
      })
      should contain_apt__source('10gen').with({
        :location => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit'
      })
    }
  end

  describe 'when deploying on ubuntu' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'edgy',
      }
    end

    it {
      should contain_class('mongodb::sources::apt')
      should contain_package('mongodb-10gen').with({
        :name => 'mongodb-10gen'
      })
      should contain_file('/etc/mongod.conf')
      should contain_service('mongodb').with({
        :name => 'mongodb'
      })
      should contain_apt__source('10gen').with({
        :location => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart'
      })
    }
  end

  describe 'when deploying on redhat' do
    let :facts do
      {
        :osfamily        => 'RedHat',
        :lsbdistcodename => 'Final',
      }
    end
    it {
      should contain_class('mongodb::sources::yum')
      should contain_package('mongodb-10gen').with({
        :name => 'mongo-10gen-server'
      })
      should contain_file('/etc/mongod.conf')
      should contain_service('mongodb').with({
        :name => 'mongod'
      })
      should contain_yumrepo('10gen')
    }
  end

  describe 'when deploying on Solaris' do
    let :facts do
      { :osfamily        => 'Solaris' }
    end
    it { expect { should raise_error(Puppet::Error) } }
  end

  describe 'when overriding init' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'edgy',
      }
    end

    let :params do
      { :init => 'sysv' }
    end

    it {
      should contain_apt__source('10gen').with({
        :location => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit'
      })
    }
  end

  describe 'when overriding location' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'edgy',
      }
    end

    let :params do
      { :location => 'http://myrepo' }
    end

    it {
      should contain_apt__source('10gen').with({
        :location => 'http://myrepo'
      })
    }
  end
end
