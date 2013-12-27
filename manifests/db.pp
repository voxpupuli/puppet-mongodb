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
#
define mongodb::db (
  $user,
  $password_hash = false,
  $password      = false,
  $roles         = ['dbAdmin'],
) {

  mongodb_database { $name:
    ensure   => present,
    require  => Class['mongodb::server'],
  }

  if $password_hash {
    $hash = $password_hash
  } elsif $password {
    $hash = mongodb_password($user, $password)
  } else {
    fail("Parameter 'password_hash' or 'password' should be provided.")
  }

  mongodb_user { $user:
    ensure        => present,
    password_hash => $hash,
    database      => $name,
    roles         => $roles,
    require       => Mongodb_database[$name],
  }

}
