# PRIVATE CLASS: do not use directly
class mongodb::mongos::params inherits mongodb::globals {
  $manage_package = pick($mongodb::globals::manage_package, $mongodb::globals::manage_package_repo, false)

  $version = $mongodb::globals::version

  $package_ensure = pick($version, 'present')
  # from versoin 4.4 on, package name is all the same in the upstream repositories
  $package_name = "mongodb-${mongodb::globals::edition}-mongos"

  $config_content = undef
  $config_template = undef

  $config_data = undef
  $configdb    = '127.0.0.1:27019'
  $bind_ip     = undef
  $port        = undef
  $restart     = true

  $service_name   = 'mongos'
  $service_manage = true
  $service_enable = true
  $service_ensure = 'running'
  $service_status = undef

  # Amazon Linux's OS Family is 'Linux', operating system 'Amazon'.
  case $facts['os']['family'] {
    'RedHat', 'Linux', 'Suse': {
      if $manage_package {
        $config           = '/etc/mongodb-shard.conf'
        $pidfilepath      = undef
        $unixsocketprefix = undef
        $logpath          = undef
        $fork             = undef
        $service_template = undef
      } else {
        # RedHat/CentOS doesn't come with a prepacked mongodb
        # so we assume that you are using EPEL repository.
        $config           = '/etc/mongos.conf'
        $pidfilepath      = '/var/run/mongodb/mongos.pid'
        $unixsocketprefix = '/var/run/mongodb'
        $logpath          = '/var/log/mongodb/mongos.log'
        $fork             = undef # https://github.com/voxpupuli/puppet-mongodb/issues/667
        $service_template = 'mongodb/mongos/RedHat/mongos.service-dropin.epp'
      }
    }
    'Debian': {
      $config           = '/etc/mongodb-shard.conf'
      $pidfilepath      = undef
      $unixsocketprefix = undef
      $logpath          = undef
      $fork             = undef
      $service_template = undef
    }
    default: {
      fail("Osfamily ${facts['os']['family']} is not supported")
    }
  }
}
