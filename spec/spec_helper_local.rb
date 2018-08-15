RSpec.configure do |config|
  config.mock_with :rspec
end

def with_debian_facts
  let :facts do
    {
      lsbdistid: 'Debian',
      lsbdistcodename: 'jessie',
      operatingsystem: 'Debian',
      operatingsystemmajrelease: 8,
      osfamily: 'Debian',
      root_home: '/root',
      os: {
        name: 'Debian',
        release: {
          major: '8'
        }
      }
    }
  end
end

def with_centos_facts
  let :facts do
    {
      architecture: 'x86_64',
      operatingsystem: 'CentOS',
      operatingsystemrelease: '7.0',
      operatingsystemmajrelease: '7',
      osfamily: 'RedHat',
      root_home: '/root',
      os: {
        name: 'CentOS',
        release: {
          major: '7'
        }
      }
    }
  end
end

def with_redhat_facts
  let :facts do
    {
      architecture: 'x86_64',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '7.0',
      operatingsystemmajrelease: '7',
      osfamily: 'RedHat',
      root_home: '/root',
      os: {
        name: 'RedHat',
        release: {
          major: '7'
        }
      }
    }
  end
end
