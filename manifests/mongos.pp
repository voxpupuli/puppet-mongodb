# @summary This installs a Mongo Shard daemon. See README.md for more details.
#
# @param config
# @param config_content
# @param config_template
# @param configdb
# @param config_data
# @param service_manage
# @param service_provider
# @param service_name
# @param service_user
# @param service_group
# @param service_template
# @param service_enable
# @param service_ensure
# @param service_status
# @param package_ensure
# @param package_name
# @param unixsocketprefix
# @param pidfilepath
# @param logpath
# @param fork
# @param bind_ip
# @param port
# @param restart
#
class mongodb::mongos (
  Stdlib::Absolutepath $config                              = $mongodb::mongos::params::config,
  Optional[String[1]] $config_content                       = $mongodb::mongos::params::config_content,
  Optional[String[1]] $config_template                      = $mongodb::mongos::params::config_template,
  Variant[String[1], Array[String[1]]] $configdb            = $mongodb::mongos::params::configdb,
  Optional[Hash] $config_data                               = $mongodb::mongos::params::config_data,
  Boolean $service_manage                                   = $mongodb::mongos::params::service_manage,
  Optional[String] $service_provider                        = $mongodb::mongos::params::service_provider,
  Optional[String] $service_name                            = $mongodb::mongos::params::service_name,
  String $service_user                                      = 'mongodb',
  String $service_group                                     = 'mongodb',
  Optional[String[1]] $service_template                     = $mongodb::mongos::params::service_template,
  Boolean $service_enable                                   = $mongodb::mongos::params::service_enable,
  Stdlib::Ensure::Service $service_ensure                   = $mongodb::mongos::params::service_ensure,
  Optional[String] $service_status                          = $mongodb::mongos::params::service_status,
  Variant[Boolean, String] $package_ensure                  = $mongodb::mongos::params::package_ensure,
  String $package_name                                      = $mongodb::mongos::params::package_name,
  Optional[Stdlib::Absolutepath] $unixsocketprefix          = $mongodb::mongos::params::unixsocketprefix,
  Optional[Stdlib::Absolutepath] $pidfilepath               = $mongodb::mongos::params::pidfilepath,
  Optional[Variant[Boolean, Stdlib::Absolutepath]] $logpath = $mongodb::mongos::params::logpath,
  Optional[Boolean] $fork                                   = $mongodb::mongos::params::fork,
  Optional[Array[Stdlib::IP::Address]] $bind_ip             = $mongodb::mongos::params::bind_ip,
  Optional[Stdlib::Port] $port                              = $mongodb::mongos::params::port,
  Boolean $restart                                          = $mongodb::mongos::params::restart,
) inherits mongodb::mongos::params {
  contain mongodb::mongos::install
  contain mongodb::mongos::config
  contain mongodb::mongos::service

  unless $package_ensure in ['absent', 'purged'] {
    Class['mongodb::mongos::install'] -> Class['mongodb::mongos::config']

    if $restart {
      # If $restart is true, notify the service on config changes (~>)
      Class['mongodb::mongos::config'] ~> Class['mongodb::mongos::service']
    } else {
      # If $restart is false, config changes won't restart the service (->)
      Class['mongodb::mongos::config'] -> Class['mongodb::mongos::service']
    }
  } else {
    Class['mongodb::mongos::service'] -> Class['mongodb::mongos::config'] -> Class['mongodb::mongos::install']
  }
}
