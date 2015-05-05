require 'spec_helper'

describe 'mongodb::mongos::service', :type => :class do

  context 'on Debian' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
      }
    end

    let :pre_condition do          
      "class { 'mongodb::mongos':
         configdb => ['127.0.0.1:27019'],
       }"
    end 

    describe 'include init script' do
      it { is_expected.to contain_file('/etc/init.d/mongos') }
    end

    describe 'configure the mongos service' do
      it { is_expected.to contain_service('mongos') }
    end
  end

  context 'on RedHat' do
    let :facts do
      {
        :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat',
      }
    end

    let :pre_condition do
      "class { 'mongodb::mongos':
         configdb => ['127.0.0.1:27019'],
       }"
    end

    describe 'include mongos sysconfig file' do
      it { is_expected.to contain_file('/etc/sysconfig/mongos') }
    end

    describe 'include init script' do
      it { is_expected.to contain_file('/etc/init.d/mongos') }
    end

    describe 'configure the mongos service' do
      it { is_expected.to contain_service('mongos') }
    end
  end


end
