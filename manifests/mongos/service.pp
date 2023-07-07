# @private
#
# @summary Manages the mongos service.
#
# @param package_ensure
#   This setting can be used to specify if puppet should install the package or not.
#
# @param service_manage
#   Whether or not the MongoDB sharding service resource should be part of the catalog.
#
# @param service_name
#   This setting can be used to override the default Mongos service name.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param service_enable
#   This setting can be used to specify if the service should be enable at boot.
#
# @param service_ensure
#   This setting can be used to specify if the service should be running.
#
# @param service_status
#   This setting can be used to override the default status check command for your Mongos service.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param service_provider
#   This setting can be used to override the default Mongos service provider.
#   If not specified, the module will use whatever service provider is the default for your OS distro.
#
# @param bind_ip
#   Set this option to configure the mongod or mongos process to bind to and listen for connections from applicati ons on this address.
#   If not specified, the module will use the default for your OS distro.
#
# @param port
#   Specifies a TCP port for the server instance to listen for client connections.
#
# @param service_template
#   Path to the service template if the default doesn't match one needs.
#
class mongodb::mongos::service (
  $package_ensure   = $mongodb::mongos::package_ensure,
  $service_manage   = $mongodb::mongos::service_manage,
  $service_name     = $mongodb::mongos::service_name,
  $service_enable   = $mongodb::mongos::service_enable,
  $service_ensure   = $mongodb::mongos::service_ensure,
  $service_status   = $mongodb::mongos::service_status,
  $service_provider = $mongodb::mongos::service_provider,
  $bind_ip          = $mongodb::mongos::bind_ip,
  $port             = $mongodb::mongos::port,
  $service_template = $mongodb::mongos::service_template,
) {
  if $package_ensure in ['absent', 'purged'] {
    $real_service_ensure = 'stopped'
    $real_service_enable = false
  } else {
    $real_service_ensure = $service_ensure
    $real_service_enable = $service_enable
  }

  if $bind_ip == '0.0.0.0' {
    $connect_ip = '127.0.0.1'
  } else {
    $connect_ip = $bind_ip
  }

  if $service_manage {
    if $facts['os']['family'] == 'RedHat' {
      systemd::unit_file { 'mongos.service':
        content => epp($service_template),
        enable  => $real_service_enable,
      } ~> Service['mongos']
    }

    service { 'mongos':
      ensure   => $real_service_ensure,
      name     => $service_name,
      enable   => $real_service_enable,
      provider => $service_provider,
      status   => $service_status,
    }

    if $real_service_ensure == 'running' {
      mongodb_conn_validator { 'mongos':
        server  => $connect_ip,
        port    => pick($port, 27017),
        timeout => '240',
        require => Service['mongos'],
      }
    }
  }
}
