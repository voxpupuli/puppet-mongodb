# @private
#
# @summary Installs mongos
#
# @param package_ensure
#   This setting can be used to specify if puppet should install the package or not
#
# @param package_name
#   This setting can be used to specify the name of the package that should be installed.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
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
