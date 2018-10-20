# PRIVATE CLASS: do not call directly
class mongodb::mongos::config (
  $package_ensure  = $mongodb::mongos::package_ensure,
  $config          = $mongodb::mongos::config,
  $config_content  = $mongodb::mongos::config_content,
  $config_template = $mongodb::mongos::config_template,
  $configdb        = $mongodb::mongos::configdb,
  $config_data     = $mongodb::mongos::config_data,
  $service_manage  = $mongodb::mongos::service_manage,
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
    if $facts['os']['family'] == 'RedHat' {
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
