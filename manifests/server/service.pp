# PRIVATE CLASS: do not call directly
class mongodb::server::service {
  $ensure           = $mongodb::server::service_ensure
  $service_enable   = $mongodb::server::service_enable
  $service_name     = $mongodb::server::service_name
  $service_provider = $mongodb::server::service_provider
  $service_status   = $mongodb::server::service_status

  $service_ensure = $ensure ? {
    present => true,
    absent  => false,
    default => $ensure
  }

  service { 'mongodb':
    ensure    => $service_ensure,
    name      => $service_name,
    enable    => $service_enable,
    provider  => $service_provider,
    hasstatus => true,
    status    => $service_status,
  }
}
