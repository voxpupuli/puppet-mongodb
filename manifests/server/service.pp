# PRIVATE CLASS: do not call directly
class mongodb::server::service {

  $ensure           = $::mongodb::server::ensure
  $service_ensure   = $::mongodb::server::service_ensure
  $service_enable   = $::mongodb::server::service_enable
  $service_name     = $::mongodb::server::service_name
  $service_provider = $::mongodb::server::service_provider
  $service_status   = $::mongodb::server::service_status
  $bind_ip          = $::mongodb::server::bind_ip
  $port             = $::mongodb::server::port

  if $service_ensure != undef {
    $my_service_ensure = $service_ensure
  } else {
    $my_service_ensure = $ensure ? {
      present => true,
      absent  => false,
      purged  => false,
      default => $ensure
    }
  }

  if $service_enable != undef {
    $my_service_enable = $service_enable
  } else {
    $my_service_enable = $my_service_ensure ? {
      present => true,
      absent  => false,
      purged  => false,
      default => $ensure
    }
  }

  service { $service_name:
    ensure    => $my_service_ensure,
    enable    => $my_service_enable,
    provider  => $service_provider,
    hasstatus => true,
    status    => $service_status,
  }

  if $my_service_ensure {
    mongodb_conn_validator { $service_name:
      server  => $bind_ip,
      port    => $port,
      timeout => '240',
      require => Service[$service_name],
    }
  }

}
