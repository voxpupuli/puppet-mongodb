# PRIVATE CLASS: do not call directly
class mongodb::mongos::install (
  $package_ensure = $mongodb::mongos::package_ensure,
  $package_name   = $mongodb::mongos::package_name,
) {
  if $facts['os']['family'] == 'Suse' and $package_ensure == 'purged' {
    $_package_ensure = 'absent'
  } else {
    $_package_ensure = $package_ensure
  }

  unless defined(Package[$package_name]) {
    package { 'mongodb_mongos':
      ensure => $_package_ensure,
      name   => $package_name,
      tag    => 'mongodb_package',
    }
  }
}
