# == Class: mongodb::server::users
#
# Class for creating mongodb users.
#
# == Parameters
#
#  users - A hash of users in mongodb_user provider format
#  userdefaults - A hash of user default settings in mongodb_user provider format
#  hieramerge - enables hiera merging
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

    $x_users        = hiera_hash('mongodb::server::users', undef)
    $x_userdefaults = hiera_hash('mongodb::server::userdefaults', undef)

  } else {
    $x_users        = $users
    $x_userdefaults = $userdefaults
  }

  if $x_users {
    create_resources('::mongodb::user', $x_users, $x_userdefaults)
  }

}

