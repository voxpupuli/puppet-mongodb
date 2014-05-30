# == Class: mongodb::server::users
#
# Class for creating mongodb users.
#
# PRIVATE CLASS: do not call directly
#
# == Parameters
#
#  users - A hash of users in mongodb::user format
#  userdefaults - An optional hash of user default settings in mongodb::user format
#  hieramerge - Enables merging for hiera based hash parameters
#
class mongodb::server::users(

  $users        = $::mongodb::server::users,
  $userdefaults = $::mongodb::server::userdefaults,
  $hieramerge   = $::mongodb::server::hieramerge

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

    $x_users        = hiera_hash('mongodb::server::users', $users)
    $x_userdefaults = hiera_hash('mongodb::server::userdefaults', $userdefaults)

  # Fall back to user provided class parameter / priority based hiera lookup
  } else {
    $x_users        = $users
    $x_userdefaults = $userdefaults
  }

  if $x_users {
    create_resources('::mongodb::user', $x_users, $x_userdefaults)
  }

}

