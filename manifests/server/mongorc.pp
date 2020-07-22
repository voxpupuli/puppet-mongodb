class mongodb::server::mongorc {
  $handle_creds   = $mongodb::server::handle_creds
  $auth           = $mongodb::server::auth
  $store_creds    = $mongodb::server::store_creds
  $rcfile         = $mongodb::server::rcfile
  $replset        = $mongodb::server::replset
  $admin_username = $mongodb::server::admin_username
  $admin_password = $mongodb::server::admin_password

  if $handle_creds {
    if $auth and $store_creds {
      file { $rcfile:
        ensure  => present,
        content => template('mongodb/mongorc.js.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
      }
    } else {
      file { $rcfile:
        ensure => absent,
      }
    }
  }
}
