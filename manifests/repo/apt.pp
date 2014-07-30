# PRIVATE CLASS: do not use directly
class mongodb::repo::apt inherits mongodb::repo {

  $ensure   = $::mongodb::repo::ensure
  $location = $::mongodb::repo::location

  # we try to follow/reproduce the instruction
  # from http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

  include ::apt

  if($ensure == 'present' or $ensure == true) {
    apt::source { 'downloads-distro.mongodb.org':
      location    => $location,
      release     => 'dist',
      repos       => '10gen',
      key         => '9ECBEC467F0CEB10',
      key_server  => 'keyserver.ubuntu.com',
      include_src => false,
    }

  }
  else {
    apt::source { 'downloads-distro.mongodb.org':
      ensure => absent,
    }
  }
}
