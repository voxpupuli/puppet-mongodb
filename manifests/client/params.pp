# PRIVATE CLASS: do not use directly
class mongodb::client::params inherits mongodb::globals {

  $manage_package_repo = $::mongodb::globals::manage_package_repo

  # Amazon Linux's OS Family is 'Linux', operating system 'Amazon'.
  case $::osfamily {
    'RedHat', 'Linux': {
      if $manage_package_repo {
        $package_name = 'mongodb-org-shell'

      } else {
        # RedHat/CentOS doesn't come with a prepacked mongodb
        # so we assume that you are using EPEL repository.

        # NOTE: use of globals is deprecated for the following vars
        $package_name = pick($::mongodb::globals::client_package_name, 'mongodb')
      }
    }

    'Debian': {
      if $manage_package_repo {
        $package_name = 'mongodb-org-shell'

      } else {
        # although we are living in a free world,
        # I would not recommend to use the prepacked
        # mongodb server on Ubuntu 12.04 or Debian 6/7,
        # because its really outdated

        # NOTE: use of globals is deprecated for the following vars
        $package_name = pick($::mongodb::globals::client_package_name, 'mongodb-server')
      }
    }

    default: {
      fail("Osfamily ${::osfamily} and ${::operatingsystem} is not supported")
    }

  }

}
