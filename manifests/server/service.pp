# PRIVATE CLASS: do not call directly
class mongodb::server::service {
  $ensure           = $mongodb::server::service_ensure
  $service_manage   = $mongodb::server::service_manage
  $service_enable   = $mongodb::server::service_enable
  $service_name     = $mongodb::server::service_name
  $service_provider = $mongodb::server::service_provider
  $service_status   = $mongodb::server::service_status
  $bind_ip          = $mongodb::server::bind_ip
  $port             = $mongodb::server::port
  $configsvr        = $mongodb::server::configsvr
  $shardsvr         = $mongodb::server::shardsvr

  if !$port {
    if $configsvr {
      $port_real = 27019
    } elsif $shardsvr {
      $port_real = 27018
    } else {
      $port_real = 27017
    }
  } else {
    $port_real = $port
  }

  if $bind_ip == '0.0.0.0' {
    $bind_ip_real = '127.0.0.1'
  } else {
    $bind_ip_real = $bind_ip
  }

  $service_ensure = $ensure ? {
    'absent'  => false,
    'purged'  => false,
    'stopped' => false,
    default   => true
  }
  if $::operatingsystem = 'Ubuntu' {
    if $service_provider = 'upstart' {
      file { '/etc/init.d/mongodb' :
        ensure  => file,
        content => template("mongodb/mongodb/Ubuntu/mongo.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        before  => Service['mongodb'],
      }
    } else {
      file { '/lib/systemd/system/mongod.service' :
        ensure  => file,
        content => template("mongodb/mongodb/Ubuntu/mongod.service.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        before  => Service['mongodb'],
      }
    }
  }

  if $service_manage {
    service { 'mongodb':
      ensure    => $service_ensure,
      name      => $service_name,
      enable    => $service_enable,
      provider  => $service_provider,
      hasstatus => true,
      status    => $service_status,
    }

    if $service_ensure {
      mongodb_conn_validator { 'mongodb':
        server  => $bind_ip_real,
        port    => $port_real,
        timeout => '240',
        require => Service['mongodb'],
      }
    }
  }

}
