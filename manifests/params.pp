# See README
class mongodb::params{

  $auth            = undef
  $cpu             = undef
  $keyfile         = undef
  $location        = ''
  $logappend       = true
  $logpath_os      = '/var/log/mongodb/mongodb.log'
  $master          = undef
  $mms_interval    = undef
  $mms_name        = undef
  $mms_token       = undef
  $noauth          = undef
  $nohints         = undef
  $nohttpinterface = undef
  $nojournal       = undef
  $noprealloc      = undef
  $noscripting     = undef
  $notablescan     = undef
  $nssize          = undef
  $objcheck        = undef
  $only            = undef
  $oplog           = undef
  $oplog_size      = undef
  $port            = '27017'
  $quota           = undef
  $replset         = undef
  $rest            = undef
  $service_enable  = true
  $service_ensure  = running
  $slave           = undef
  $slowms          = undef
  $smallfiles      = undef
  $verbose         = undef
  $package_ensure  = present

  case $::osfamily {
    'redhat': {
      $repo_location = "http://downloads-distro.mongodb.org/repo/redhat/os/${::architecture}"
      $service_name  = 'mongod'
      $source        = 'mongodb::sources::yum'
      $config_name   = '/etc/mongod.conf'
      $bind_ip       = '127.0.0.1'
      $fork          = true
      $journal       = true

      $package_name = {
        '10gen'  => 'mongo-10gen-server',
        'distro' => 'mongodb-server'
      }
      $user = {
        '10gen'  => 'mongod',
        'distro' => 'mongodb',
      }
      $group = {
        '10gen'  => 'mongod',
        'distro' => 'mongodb',
      }
      $dbpath_name = {
        '10gen'  => '/var/lib/mongo',
        'distro' => '/var/lib/mongodb',
      }
      $logpath_name = {
        '10gen'  => '/var/log/mongo/mongod.log',
        'distro' => '/var/log/mongodb/mongodb.log',
      }
      $pidfilepath = {
        '10gen'  => '/var/run/mongodb/mongod.pid',
        'distro' => '/var/run/mongodb/mongodb.pid',
      }
    }
    'debian': {
      $source      = 'mongodb::sources::apt'
      $service     = 'mongodb'
      $config_name = '/etc/mongodb.conf'
      $bind_ip     = '127.0.0.1'
      $fork        = true
      $journal     = true

      $repo_location = $::operatingsystem ? {
        'Debian'    => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
        'Ubuntu'    => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart'
      }
      $init = $::operatingsystem ? {
        'Debian' => 'sysv',
        'Ubuntu' => 'upstart',
      }
      $package_name = {
        '10gen'  => 'mongodb-10gen',
        'distro' => 'mongodb'
      }
      $dbpath_name  = {
        '10gen'  => '/var/lib/mongodb',
        'distro' => '/var/lib/mongodb',
      }
      $user = {
        '10gen'  => 'mongodb',
        'distro' => 'mongodb',
      }
      $group = {
        '10gen'  => 'mongodb',
        'distro' => 'mongodb',
      }
      $logpath_name = {
        '10gen'  => '/var/log/mongodb/mongodb.log',
        'distro' => '/var/log/mongodb/mongodb.log',
      }
      $pidfilepath = {
        '10gen'  => '/var/run/mongodb/mongodb.pid',
        'distro' => '/var/run/mongodb/mongodb.pid',
      }

    }
    default: {
      fail ("mongodb: ${::operatingsystem} is not supported.")
    }
  }

}
