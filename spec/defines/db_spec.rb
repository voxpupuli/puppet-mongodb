require 'spec_helper'

describe 'mongodb::db', :type => :define do
  let(:title) { 'testdb' }

  let(:params) {
    { 'user'     => 'testuser',
      'password' => 'testpass',
    }
  }

  it 'should contain mongodb_database with mongodb::server requirement' do
    should contain_mongodb_database('testdb')\
      .with_require('Class[Mongodb::Server]')
  end

  it 'should contain mongodb_user with mongodb_database requirement' do
    should contain_mongodb_user('testuser')\
      .with_require('Mongodb_database[testdb]')
  end

  it 'should contain mongodb_user with proper database name' do
    should contain_mongodb_user('testuser')\
      .with_database('testdb')
  end

  it 'should contain mongodb_user with proper roles' do
    params.merge!({'roles' => ['testrole1', 'testrole2']})
    should contain_mongodb_user('testuser')\
      .with_roles(["testrole1", "testrole2"])
  end
end
