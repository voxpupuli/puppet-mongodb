require 'spec_helper'

shared_context 'os_neutral' do
  it {
    should contain_class('mongodb::client::install')
  }
end

describe 'mongodb::client', :type => :class do

  context 'when deploying on RedHat' do
    let (:facts) { { :osfamily => 'RedHat' } }
    include_context 'os_neutral'
  end

  context 'when deploying on Debian' do
    let (:facts) { { :osfamily => 'Debian' } }
    include_context 'os_neutral'
  end

end
