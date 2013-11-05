require 'spec_helper_system'

describe 'mongodb class' do
  case node.facts['osfamily']
  when 'RedHat'
    package_name = 'mongodb-server'
    service_name = 'mongod'
    config_name  = '/etc/mongod.conf'
  when 'Debian'
    package_name = 'mongodb'
    service_name = 'mongodb'
    config_name  = '/etc/mongodb.conf'
  end

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'mongodb': }
      EOS

      # Run it twice and test for idempotency
      puppet_apply(pp) do |r|
        r.exit_code.should eq 2
        r.refresh
        r.exit_code.should be_zero
      end
    end
  end

  describe 'mongodb::install' do
    describe package(package_name) do
      it { should be_installed }
    end
  end

  describe 'mongodb::config' do
    describe file(config_name) do
      it { should be_file }
    end
  end

  describe 'mongodb::service' do
    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe 'cleanup' do
    it 'uninstalls mongodb' do
      shell("puppet resource package #{package_name} ensure=absent")
      shell('rm -rf /var/lib/mongodb')
      shell('rm -rf /etc/mongo*')
    end
  end

end
