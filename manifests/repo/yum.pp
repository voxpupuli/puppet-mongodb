# PRIVATE CLASS: do not use directly
class mongodb::repo::yum {

  $ensure   = $::mongodb::repo::ensure
  $location = $::mongodb::repo::location

  # We try to follow/reproduce the instruction
  # http://docs.mongodb.org/manual/tutorial/install-mongodb-on-red-hat-centos-or-fedora-linux/

  if($ensure == 'present' or $ensure == true) {
    yumrepo { 'mongodb':
      descr    => 'MongoDB/10gen Repository',
      baseurl  => $location,
      gpgcheck => '0',
      enabled  => '1',
    }
  }
  else {
    yumrepo { 'mongodb':
      enabled => absent,
    }
  }
}
