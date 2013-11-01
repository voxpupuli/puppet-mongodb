require 'spec_helper_system'

describe 'mongodb::config' do

  it 'runs setup' do
    pp = <<-EOS
    class { 'mongodb': }
    EOS
    puppet_apply(pp)
  end

  describe file('/etc/mongodb.conf') do
    it { should be_file }
  end
    
end
