require 'spec_helper'

describe 'mongodb', :type => :class do

  describe 'when deploying on debian' do
    let :facts do
      {
        :operatingsystem => 'Debian',
        :lsbdistcodename => 'sid',
      }
    end

    it { should contain_class('apt') }
    it { should contain_package('mongodb-10gen') }
    it { should contain_apt__source('10gen').with({
      'location' => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
    }) }
  end

  describe 'when deploying on ubuntu' do
    let :facts do
      {
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'edgy',
      }
    end

    it { should contain_class('apt') }
    it { should contain_package('mongodb-10gen') }
    it { should contain_apt__source('10gen').with({
      'location' => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart',
    }) }
  end

  describe 'when deploying on redhat' do
    let :facts do
      {
        :operatingsystem => 'RedHat',
        :lsbdistcodename => 'Final',
      }
    end
    it { expect { should raise_error(Puppet::Error) } }
  end

  describe 'when overriding init' do
    let :facts do
      {
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'edgy',
      }
    end

    let :params do
      {  :init => 'sysv' }
    end

    it { should contain_class('apt') }
    it { should contain_package('mongodb-10gen') }
    it { should contain_apt__source('10gen').with({
      'location' => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
    }) }
  end
end
