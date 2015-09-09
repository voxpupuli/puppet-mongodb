# == Class: mongodb::db
#
# Class for creating mongodb databases and users.
#
# == Parameters
#
#  user - Database username.
#  password_hash - Hashed password. Hex encoded md5 hash of "$username:mongo:$password".
#  password - Plain text user password. This is UNSAFE, use 'password_hash' unstead.
#  roles (default: ['dbAdmin']) - array with user roles.
#  tries (default: 10) - The maximum amount of two second tries to wait MongoDB startup.
#
define mongodb::db (
  $user,
  $password_hash = undef,
  $password      = undef,
  $roles         = ['dbAdmin'],
  $tries         = 10,
) {

  mongodb_database { $name:
    ensure  => present,
    tries   => $tries,
    require => Class['mongodb::server'],
  }

  mongodb_user { "User ${user} on db ${name}":
    ensure        => present,
    password_hash => $password_hash,
    password      => $password,
    username      => $user,
    database      => $name,
    roles         => $roles,
    require       => Mongodb_database[$name],
  }

}
