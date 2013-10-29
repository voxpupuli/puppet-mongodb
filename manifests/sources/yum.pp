class mongodb::sources::yum inherits mongodb::params {
  yumrepo { '10gen':
    name      => '10gen repo',
    baseurl   => $mongodb::params::baseurl,
    gpgcheck  => '0',
    enabled   => '1',
  }
}
