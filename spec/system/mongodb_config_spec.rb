require 'spec_helper_system'

describe 'mongodb::config' do
  case node.facts['osfamily']
  when 'RedHat'
    config_file = '/etc/mongod.conf'
  when 'Debian'
    config_file = '/etc/mongodb.conf'
  end

  it 'runs setup' do
    pp = <<-EOS
    class { 'mongodb': }
    EOS
    puppet_apply(pp)
  end

  describe file(config_file) do
    it { should be_file }
  end
    
end
