# @summary This installs a Mongo Shard daemon.
#
# This class should only be used if you want to implement sharding within your mongodb deployment.
#  This class allows you to configure the mongos daemon (responsible for routing) on your platform.
#
# @example mongos can be installed the following way.
#   class {'mongodb::mongos' :
#    configdb => ['configsvr1.example.com:27018'],
#  }
#
# @param config
#   Path of the config file. If not specified, the module will use the default for your OS distro.
#
# @param config_content
#   Config content if the default doesn't match one needs.
#
# @param config_template
#   Path to the config template if the default doesn't match one needs.
#
# @param configdb
#   Array of the config servers IP addresses the mongos should connect to.
#
# @param config_data
#   Hash containing key-value pairs to allow for additional configuration options to be set in user-provided template.
#
# @param service_manage
#   Whether or not the MongoDB sharding service resource should be part of the catalog.
#
# @param service_provider
#   This setting can be used to override the default Mongos service provider.
#   If not specified, the module will use whatever service provider is the default for your OS distro.
#
# @param service_name
#   This setting can be used to override the default Mongos service name.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param service_template
#   Path to the service template if the default doesn't match one needs.
#
# @param service_enable
#   This setting can be used to specify if the service should be enable at boot
#
# @param service_ensure
#   This setting can be used to specify if the service should be running
#
# @param service_status
#   This setting can be used to override the default status check command for your Mongos service.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param package_ensure
#   This setting can be used to specify if puppet should install the package or not
#
# @param package_name
#   This setting can be used to specify the name of the package that should be installed.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param unixsocketprefix
#   The path for the UNIX socket. If this option has no value, the mongos process creates a socket with /tmp as a prefix.
#
# @param pidfilepath
#   Specify a file location to hold the PID or process ID of the mongod process.
#   If not specified, the module will use the default for your OS distro.
#
# @param logpath
#   Specify the path to a file name for the log file that will hold all diagnostic logging information.
#   Unless specified, mongod will output all log information to the standard output.
#
# @param fork
#   Set to true to fork server process at launch time. The default setting depends on the operating system.
#
# @param bind_ip
#   Set this option to configure the mongod or mongos process to bind to and listen for connections from applications on this address.
#   If not specified, the module will use the default for your OS distro.
#
# @param port
#   Specifies a TCP port for the server instance to listen for client connections.
#
# @param restart
#   Specifies whether the service should be restarted on config changes.
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
