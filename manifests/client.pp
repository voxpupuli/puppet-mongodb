# @summary Class for installing a MongoDB client shell (CLI).
#
# @example Basic usage
# include mongodb::client

# @param ensure
#   Used to ensure that the package is installed, or that the package is absent/purged
#
# @param package_name
#   This setting can be used to specify the name of the package that should be installed.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
class mongodb::client (
  String[1] $ensure = $mongodb::client::params::package_ensure,
  String[1] $package_name = $mongodb::client::params::package_name,
) inherits mongodb::client::params {
  package { 'mongodb_client':
    ensure => $ensure,
    name   => $package_name,
    tag    => 'mongodb_package',
  }
}
