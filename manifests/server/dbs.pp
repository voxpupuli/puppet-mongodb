# == Class: mongodb::server::dbs
#
# Class for creating mongodb databases and users.
#
# == Parameters
#
#  databases - A hash of databases in mongodb::db format
#  dbdefaults - A hash of database default settings in mongodb::db format
#  hieramerge - enables hiera merging
#
class mongodb::server::dbs(

  $databases  = $::mongodb::server::databases,
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

    $x_databases  = hiera_hash('mongodb::server::databases', undef)
    $x_dbdefaults = hiera_hash('mongodb::server::dbdefaults', undef)

  } else {
    $x_databases  = $databases
    $x_dbdefaults = $dbdefaults
  }

  if $x_databases {
    create_resources('::mongodb::db', $x_databases, $x_dbdefaults)
  }

}

