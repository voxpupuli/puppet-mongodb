class mongodb::sources::yum inherits mongodb::params {
  yumrepo { '10gen':
    descr     => '10gen repo',
    baseurl   => $mongodb::params::baseurl,
    gpgcheck  => '0',
    enabled   => '1',
  }
}
