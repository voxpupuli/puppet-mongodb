require 'spec_helper_system'

describe 'mongodb::service' do

  it 'runs setup' do
    pp = <<-EOS
    class { 'mongodb': }
    EOS
    puppet_apply(pp)
  end

  describe service('mongodb') do
    it { should be_enabled }
    it { should be_running }
  end
    
end
