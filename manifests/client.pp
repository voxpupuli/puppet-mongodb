# Class for installing a MongoDB client shell (CLI).
#
# == Parameters
#
# [ensure] Desired ensure state of the package. Optional.
#   Defaults to 'true'
#
# [package_name] Name of the package to install the client from. Default
#   is repository dependent.
#
class mongodb::client (

  $ensure       = true,
  $package_name = $::mongodb::client::params::package_name

) inherits mongodb::client::params {

  include '::mongodb::client::install'

}
