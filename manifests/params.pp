class mongodb::params{
  case $::osfamily {
    'redhat': {
      $baseurl = "http://downloads-distro.mongodb.org/repo/redhat/os/${::architecture}"
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

  $mongo_user_os = 'mongodb'
  $mongo_group_os = 'mongodb'
  $mongo_user_10gen = 'mongod'
  $mongo_group_10gen = 'mongod'

  $dbpath_os = '/var/lib/mongodb/'
  $dbpath_10gen = '/var/lib/mongo/'

  $logpath_os = '/var/log/mongodb/mongodb.log'
  $logpath_10gen = '/var/log/mongo/mongod.log'

}
