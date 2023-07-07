# @summary This is a repo class for zypper
#
# This is a private class and cannot be used from outside this module.
#
# @author Frank Brehm <frank@brehm-online.com>
#
# @api private
#
class mongodb::repo::zypper inherits mongodb::repo {
  # We try to follow/reproduce the instruction
  # http://docs.mongodb.org/manual/tutorial/install-mongodb-on-red-hat-centos-or-fedora-linux/

  assert_private()

  if $mongodb::repo::ensure == 'present' or $mongodb::repo::ensure == true {
    zypprepo { 'mongodb':
      descr    => $mongodb::repo::description,
      baseurl  => $mongodb::repo::location,
      gpgcheck => '0',
      enabled  => '1',
    }
    Zypprepo['mongodb'] -> Package<| tag == 'mongodb_package' |>
  }
  else {
    zypprepo { 'mongodb':
      ensure => absent,
    }
  }
}
