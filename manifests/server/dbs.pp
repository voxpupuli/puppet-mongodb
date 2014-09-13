# == Class: mongodb::server::dbs
#
# Class for creating mongodb databases and users.
#
# PRIVATE CLASS: do not call directly
#
# == Parameters
#
#  dbs - A hash of databases in mongodb::db format
#  dbdefaults - An optional hash of database default settings in mongodb::db format
#  hieramerge - Enables merging for hiera based hash parameters
#
class mongodb::server::dbs(

  $dbs        = $::mongodb::server::dbs,
  $dbdefaults = $::mongodb::server::dbdefaults,
  $hieramerge = $::mongodb::server::hieramerge

) {

  # Load the Hiera based database definitions (if enabled and present)
  #
  # NOTE: hiera hash merging does not work in a parameterized class
  #   definition; so we call it here.
  #
  # http://docs.puppetlabs.com/hiera/1/puppet.html#limitations
  # https://tickets.puppetlabs.com/browse/HI-118
  #
  if $hieramerge {

    $x_dbs        = hiera_hash('mongodb::server::dbs', $dbs)
    $x_dbdefaults = hiera_hash('mongodb::server::dbdefaults', $dbdefaults)

  # Fall back to user provided class parameter / priority based hiera lookup
  } else {
    $x_dbs        = $dbs
    $x_dbdefaults = $dbdefaults
  }

  if $x_dbs {
    create_resources('::mongodb::db', $x_dbs, $x_dbdefaults)
  }

}

