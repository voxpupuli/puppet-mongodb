# @private
# @summary Configs mongos
#
# @param package_ensure
#   This setting can be used to specify if puppet should install the package or not
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
# @param service_manage
#   Whether or not the MongoDB sharding service resource should be part of the catalog.
#
# @param configdb
#   Array of the config servers IP addresses the mongos should connect to.
#
# @param bind_ip
#   Set this option to configure the mongod or mongos process to bind to and listen for connections from applications on this address.
#   If not specified, the module will use the default for your OS distro.
#
# @param port
#   Specifies a TCP port for the server instance to listen for client connections.
#
# @param fork
#   Set to true to fork server process at launch time. The default setting depends on the operating system.
#
# @param pidfilepath
#   Specify a file location to hold the PID or process ID of the mongod process.
#   If not specified, the module will use the default for your OS distro.
#
# @param logpath
#   Specify the path to a file name for the log file that will hold all diagnostic logging information.
#   Unless specified, mongod will output all log information to the standard output.
#
# @param unixsocketprefix
#   The path for the UNIX socket. If this option has no value, the mongos process creates a socket with /tmp as a prefix.
#
# @param config_data
#   Hash containing key-value pairs to allow for additional configuration options to be set in user-provided templ ate.
#
class mongodb::mongos::config (
  $package_ensure   = $mongodb::mongos::package_ensure,
  $config           = $mongodb::mongos::config,
  $config_content   = $mongodb::mongos::config_content,
  $config_template  = $mongodb::mongos::config_template,
  $service_manage   = $mongodb::mongos::service_manage,
  # Used in the template
  $configdb         = $mongodb::mongos::configdb,
  $bind_ip          = $mongodb::mongos::bind_ip,
  $port             = $mongodb::mongos::port,
  $fork             = $mongodb::mongos::fork,
  $pidfilepath      = $mongodb::mongos::pidfilepath,
  $logpath          = $mongodb::mongos::logpath,
  $unixsocketprefix = $mongodb::mongos::unixsocketprefix,
  $config_data      = $mongodb::mongos::config_data,
) {
  if $package_ensure == 'purged' {
    $ensure = 'absent'
  } else {
    $ensure = 'file'
  }

  #Pick which config content to use
  if $config_content {
    $config_content_real = $config_content
  } else {
    # Template has $config_data hash available
    $config_content_real = template(pick($config_template, 'mongodb/mongodb-shard.conf.erb'))
  }

  file { $config:
    ensure  => $ensure,
    content => $config_content_real,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $service_manage {
    if $facts['os']['family'] == 'RedHat' or $facts['os']['family'] == 'Suse' {
      file { '/etc/sysconfig/mongos' :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "OPTIONS=\"--quiet -f ${config}\"\n",
      }
    } elsif $facts['os']['family'] == 'Debian' {
      file { '/etc/init.d/mongos' :
        ensure  => $ensure,
        content => template('mongodb/mongos/Debian/mongos.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
      }
    }
  }
}
