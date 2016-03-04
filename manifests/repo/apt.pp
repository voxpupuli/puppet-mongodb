# PRIVATE CLASS: do not use directly
class mongodb::repo::apt inherits mongodb::repo {
  # we try to follow/reproduce the instruction
  # from http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

  include ::apt

  if($::mongodb::repo::ensure == 'present' or $::mongodb::repo::ensure == true) {
    apt::source { 'mongodb':
      location    => $::mongodb::repo::location,
      release     => $::mongodb::repo::apt_release,
      repos       => $::mongodb::repo::apt_repos,
      key         => $::mongodb::repo::apt_key,
      key_server  => 'hkp://keyserver.ubuntu.com:80',
      include_src => false,
    }
    Class['apt::update']->Package<|tag == 'mongodb'|>
  }
  else {
    apt::source { 'mongodb':
      ensure => absent,
    }
  }
}
