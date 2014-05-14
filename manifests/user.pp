# == Define: mongodb::users
#
# Define for creating mongodb users.
#
# == Parameters
#
#  database - Database name.
#  password_hash - Hashed password. Hex encoded md5 hash of "$username:mongo:$password".
#  password - Plain text user password. This is UNSAFE, use 'password_hash' unstead.
#  roles (default: ['dbAdmin']) - array with user roles.
#
define mongodb::user (
  $database,
  $password_hash = false,
  $password      = false,
  $roles         = ['dbAdmin'],
) {

  if $password_hash {
    $hash = $password_hash
  } elsif $password {
    $hash = mongodb_password($name, $password)
  } else {
    fail("Parameter 'password_hash' or 'password' should be provided to mongodb::db.")
  }

  mongodb_user { $name:
    ensure        => present,
    password_hash => $hash,
    database      => $database,
    roles         => $roles,
    require       => Mongodb_database[$database],
  }

}
