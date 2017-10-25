# Class for installing MongoDB tools (CLI).
#
# == Parameters
#
# $ensure:: Desired ensure state of the package.
#
# $package_name:: Name of the package to install the tools from. Default
#   is repository dependent.
#
class mongodb::tools (
  Variant[String, Boolean] $ensure = $mongodb::params::package_ensure_tools,
  Optional[String] $package_name = $mongodb::params::tools_package_name,
) inherits mongodb::params {
  case $ensure {
    true:     {
      $my_package_ensure = 'present'
    }
    false:    {
      $my_package_ensure = 'purged'
    }
    'absent': {
      $my_package_ensure = 'purged'
    }
    default:  {
      $my_package_ensure = $ensure
    }
  }

  if $package_name {
    package { 'mongodb_tools':
      ensure => $my_package_ensure,
      name   => $package_name,
      tag    => 'mongodb',
    }
  }
}
