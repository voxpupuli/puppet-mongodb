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
# @param service_user
#   The user used by Systemd for running the service.
#   If not specified, the module will use the default for your OS distro.
#
# @param service_group
#   The group used by Systemd for running the service
#   If not specified, the module will use the default for your OS distro.
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
  String[1] $service_user,
  String[1] $service_group,
  Stdlib::Absolutepath $config                       = '/etc/mongos.conf',
  Optional[String[1]] $config_content                = undef,
  Optional[String[1]] $config_template               = undef,
  Variant[String[1], Array[String[1]]] $configdb     = '127.0.0.1:27019',
  Optional[Hash] $config_data                        = undef,
  Boolean $service_manage                            = true,
  Optional[String] $service_provider                 = undef,
  String[1] $service_name                            = 'mongos',
  String[1] $service_template                        = 'mongodb/mongos/mongos.service-dropin.epp',
  Boolean $service_enable                            = true,
  Stdlib::Ensure::Service $service_ensure            = 'running',
  Optional[String] $service_status                   = undef,
  String[1] $package_ensure                          = pick($mongodb::globals::version, 'present'),
  String $package_name                               = "mongodb-${mongodb::globals::edition}-mongos",
  Stdlib::Absolutepath $unixsocketprefix             = '/var/run/mongodb',
  Stdlib::Absolutepath $pidfilepath                  = '/var/run/mongodb/mongos.pid',
  Variant[Boolean, Stdlib::Absolutepath] $logpath    = '/var/log/mongodb/mongos.log',
  Boolean $fork                                      = true,
  Optional[Array[Stdlib::IP::Address]] $bind_ip      = undef,
  Optional[Stdlib::Port] $port                       = undef,
  Boolean $restart                                   = true,
) inherits mongodb::globals {
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
