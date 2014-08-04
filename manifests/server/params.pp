# PRIVATE CLASS: do not use directly
class mongodb::server::params inherits mongodb::globals {

  $manage_package_repo = $::mongodb::globals::manage_package_repo

  # Amazon Linux's OS Family is 'Linux', operating system 'Amazon'.
  case $::osfamily {
    'RedHat', 'Linux': {
      if $manage_package_repo {

        $package_name   = 'mongodb-org-server'
        $config         = '/etc/mongod.conf'
        $dbpath         = '/var/lib/mongodb'
        $logpath        = '/var/log/mongodb/mongod.log'
        $pidfilepath    = '/var/run/mongodb/mongod.pid'
        $fork           = true

        # NOTE: use of globals is deprecated for the following vars
        $service_name   = pick($::mongodb::globals::service_name, 'mongod')

      } else {
        # RedHat/CentOS doesn't come with a prepacked mongodb
        # so we assume that you are using EPEL repository.

        $config         = '/etc/mongodb.conf'
        $dbpath         = '/var/lib/mongodb'
        $logpath        = '/var/log/mongodb/mongodb.log'
        $pidfilepath    = '/var/run/mongodb/mongodb.pid'
        $fork           = true
        $journal        = true

        # NOTE: use of globals is deprecated for the following vars
        $service_name = pick($::mongodb::globals::service_name, 'mongod')
        $package_name = pick($::mongodb::globals::server_package_name, 'mongodb-server')
      }
    }

    'Debian': {
      if $manage_package_repo {

        $package_name   = 'mongodb-org-server'
        $config         = '/etc/mongod.conf'
        $dbpath         = '/var/lib/mongodb'
        $logpath        = '/var/log/mongodb/mongodb.log'

        # NOTE: use of globals is deprecated for the following vars
        $service_name   = pick($::mongodb::globals::service_name, 'mongod')

      } else {
        # although we are living in a free world,
        # I would not recommend to use the prepacked
        # mongodb server on Ubuntu 12.04 or Debian 6/7,
        # because its really outdated

        $config         = '/etc/mongodb.conf'
        $dbpath         = '/var/lib/mongodb'
        $logpath        = '/var/log/mongodb/mongodb.log'
        $pidfilepath    = undef

        # NOTE: use of globals is deprecated for the following vars
        $service_name   = pick($::mongodb::globals::service_name, 'mongodb')
        $package_name   = pick($::mongodb::globals::server_package_name, 'mongodb-server')
      }

      # avoid using fork because of the init scripts design
      $fork = undef

    }

    default: {
      fail("Osfamily ${::osfamily} and ${::operatingsystem} is not supported")
    }
  }

}
