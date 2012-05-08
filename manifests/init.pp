# Class: mongodb
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Usage:
#
class mongodb (
  $init = undef
) {

  # Install sysv or upstart package based on user override or best effort.
  if $init == 'sysv' {
    $location = 'http://downloads-distro.mongodb.org/repo/debian-sysvinit'
  } elsif $init == 'upstart' {
    $location = 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart'
  } else {
    case $::operatingsystem {
      'Debian': {
        $location = 'http://downloads-distro.mongodb.org/repo/debian-sysvinit'
      }
      'Ubuntu': {
        $location = 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart'
      }
      default: {
        fail("mongrodb: operatingsystem ${::operatingsystem} is not supported.")
      }
    }
  }

  include 'apt'

  # The configuration doesn't follow convention, so release, repos is odd:
  # http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages
  apt::source { '10gen':
    location    => $location,
    release     => 'dist',
    repos       => '10gen',
    key         => '7F0CEB10',
    key_server  => 'keyserver.ubuntu.com',
    include_src => false,
    before      => Package['mongodb-10gen'],
  }

  package { 'mongodb-10gen':
    ensure => present,
  }

  service { 'mongodb':
    ensure  => running,
    enable  => true,
    require => Package['mongodb-10gen'],
  }

}
