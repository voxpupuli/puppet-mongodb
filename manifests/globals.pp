# Class for setting cross-class global overrides. See README.md for more
# details.

class mongodb::globals (

  $user                 = undef,
  $group                = undef,
  $bind_ip              = undef,
  $service_provider     = undef,
  $version              = undef,
  $manage_package_repo  = undef,

  # **** Deprecated parameters ****
  $server_package_name  = undef,  # DEPRECATED
  $client_package_name  = undef,  # DEPRECATED

  $service_enable       = undef,  # DEPRECATED
  $service_ensure       = undef,  # DEPRECATED
  $service_name         = undef,  # DEPRECATED
  $service_status       = undef,  # DEPRECATED

) {

  # **** Deprecated parameter warnings ****
  if $server_package_name {
    warning("${name} - use of deprecated parameter 'server_package_name'")
  }
  if $client_package_name {
    warning("${name} - use of deprecated parameter 'client_package_name'")
  }
  if $service_enable {
    warning("${name} - use of deprecated parameter 'service_enable'")
  }
  if $service_ensure {
    warning("${name} - use of deprecated parameter 'service_ensure'")
  }
  if $service_name {
    warning("${name} - use of deprecated parameter 'service_name'")
  }
  if $service_status {
    warning("${name} - use of deprecated parameter 'service_status'")
  }

  $default_bind_ip = pick($bind_ip, ['127.0.0.1'])

  # Amazon Linux's OS Family is 'Linux', operating system 'Amazon'.
  case $::osfamily {
    'RedHat', 'Linux': {

      if $manage_package_repo {
        $default_user     = pick($user, 'mongod')
        $default_group    = pick($group, 'mongod')
      } else {
        # RedHat/CentOS doesn't come with a prepacked mongodb
        # so we assume that you are using EPEL repository.
        $default_user     = pick($user, 'mongodb')
        $default_group    = pick($group, 'mongodb')
      }

    }

    'Debian': {

      if $manage_package_repo {
        $default_user     = pick($user, 'mongodb')
        $default_group    = pick($group, 'mongodb')
      } else {
        # although we are living in a free world,
        # I would not recommend to use the prepacked
        # mongodb server on Ubuntu 12.04 or Debian 6/7,
        # because its really outdated
        $default_user                 = pick($user, 'mongodb')
        $default_group    = pick($group, 'mongodb')
      }

    }

    default: {
      fail("Osfamily ${::osfamily} and ${::operatingsystem} is not supported")
    }

  }

  case $::operatingsystem {
    'Ubuntu': {
      $default_service_provider = pick($service_provider, 'upstart')
    }
    default: {
      $default_service_provider = undef
    }
  }

}
