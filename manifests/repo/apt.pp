# PRIVATE CLASS: do not use directly
class mongodb::repo::apt inherits mongodb::repo {
  # we try to follow/reproduce the instruction
  # from http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

  include ::apt

  if($::mongodb::repo::ensure == 'present' or $::mongodb::repo::ensure == true) {
    apt::source { 'mongodb':
      location    => $::mongodb::repo::location,
      release     => $::mongodb::repo::release,
      repos       => $::mongodb::repo::repos,
      key         => '42F3E95A2C4F08279C4960ADD68FA50FEA312927',
      key_server  => 'hkp://keyserver.ubuntu.com:80',
      include_src => false,
    }
    #remove the old and unfortunately named repos
    apt::source { 'downloads-distro.mongodb.org':
      ensure => absent,
    }
    apt::source { 'repo.mongodb.org':
      ensure => absent,
    }
    Class['apt::update']->Package<|tag == 'mongodb'|>
  }
  else {
    apt::source { 'mongodb':
      ensure => absent,
    }
    apt::source { 'downloads-distro.mongodb.org':
      ensure => absent,
    }
  }
}
