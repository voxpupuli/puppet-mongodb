class mongodb::params{
  case $::osfamily {
    'redhat': {
      case $::architecture {
        /i386|i686/: {
          $baseurl = 'http://downloads-distro.mongodb.org/repo/redhat/os/i686'
        }
        'x86_64':{
          $baseurl = 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64'
        }
        default:{
          $baseurl = 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64'
        }
      }
      $source  = 'mongodb::sources::yum'
      $package = 'mongodb-server'
      $service = 'mongod'
      $pkg_10gen = 'mongo-10gen-server'
    }
    'debian': {
      $locations = {
        'sysv'    => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
        'upstart' => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart'
      }
      case $::operatingsystem {
        'Debian': { $init = 'sysv' }
        'Ubuntu': { $init = 'upstart' }
      }
      $source  = 'mongodb::sources::apt'
      $package = 'mongodb'
      $service = 'mongodb'
      $pkg_10gen = 'mongodb-10gen'
    }
    default: {
      fail ("mongodb: ${::operatingsystem} is not supported.")
    }
  }
}
