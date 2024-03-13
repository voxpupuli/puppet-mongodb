# @summary Manages the mongos service
#
# @api private
#
# @param package_ensure
# @param service_manage
# @param service_name
# @param service_enable
# @param service_ensure
# @param service_status
# @param service_provider
# @param bind_ip
# @param port
# @param service_template
#
class mongodb::mongos::service (
  $package_ensure   = $mongodb::mongos::package_ensure,
  $service_manage   = $mongodb::mongos::service_manage,
  $service_name     = $mongodb::mongos::service_name,
  $service_user     = $mongodb::mongos::service_user,
  $service_group    = $mongodb::mongos::service_group,
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
    systemd::unit_file { 'mongos.service':
      content => epp($service_template, { service_user => $service_user, service_group => $service_user }),
      enable  => $real_service_enable,
    } ~> Service['mongos']

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
