# == Class: mongodb::server::replsets
#
# Class for creating mongodb replica sets.
#
# PRIVATE CLASS: do not call directly
#
# == Parameters
#
#  replsets - A hash of replica sets in mongodb_replset provider format
#  replsetdefaults - A hash of replica set defaults in mongodb_replset provider format
#  hieramerge - Enables merging for hiera based hash parameters
#
class mongodb::server::replsets(

  $replsets         = $::mongodb::server::replsets,
  $replsetdefaults  = $::mongodb::server::replsetdefaults,
  $hieramerge       = $::mongodb::server::hieramerge

) {

  # Load the Hiera based replica sets (if enabled and present)
  #
  # NOTE: hiera hash merging does not work in a parameterized class
  #   definition; so we call it here.
  #
  # http://docs.puppetlabs.com/hiera/1/puppet.html#limitations
  # https://tickets.puppetlabs.com/browse/HI-118
  #
  if $hieramerge {
    $x_replsets         = hiera_hash('mongodb::server::replsets', $replsets)
    $x_replsetdefaults  = hiera_hash('mongodb::server::replsetdefaults', $replsetdefaults)

  } else {
    $x_replsets         = $replsets
    $x_replsetdefaults  = $replsetdefaults
  }

  if $x_replsets {
    create_resources('mongodb_replset', $x_replsets, $x_replsetdefaults)
  }

}

