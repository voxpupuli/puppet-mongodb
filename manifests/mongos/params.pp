# @summary mongos params
#
# @api private
#
class mongodb::mongos::params inherits mongodb::globals {
  $manage_package = pick($mongodb::globals::manage_package, $mongodb::globals::manage_package_repo, false)

  $version = $mongodb::globals::version

  $package_ensure = pick($version, 'present')
  if $manage_package {
    $package_name = "mongodb-${mongodb::globals::edition}-mongos"
  } elsif $facts['os']['family'] in ['RedHat', 'Suse'] {
    $package_name = "mongodb-${mongodb::globals::edition}-mongos"
  } else {
    $package_name = 'mongodb-server'
  }

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

  $config           = '/etc/mongos.conf'
  $pidfilepath      = '/var/run/mongodb/mongos.pid'
  $unixsocketprefix = '/var/run/mongodb'
  $logpath          = '/var/log/mongodb/mongos.log'
  $fork             = true
  $service_template = 'mongodb/mongos/mongos.service-dropin.epp'
}
