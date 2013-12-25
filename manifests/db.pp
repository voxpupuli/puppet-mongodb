# == Class: mongodb::db
#
# Class for creating mongodb databases and users.
#
# == Parameters
#
#  user - Database username.
#  password - Database user password.
#  roles (default: ['dbAdmin']) - array with user roles.
#
define mongodb::db (
  $user,
  $password,
  $roles = ['dbAdmin'],
) {

  mongodb_database { $name:
    ensure   => present,
    require  => Class['mongodb::server'],
  }

  mongodb_user { $user:
    ensure        => present,
    password_hash => mongodb_password($user, $password),
    database      => $name,
    roles         => $roles,
    require       => Mongodb_database[$name],
  }

}
