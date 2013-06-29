class mongodb::sources::yum inherits mongodb::params {
  yumrepo { '10gen':
    baseurl   => $mongodb::params::baseurl,
    gpgcheck  => '0',
    enabled   => '1',
  }
  file {'10gen_repofile':
    ensure  => 'file',
    group   => 'root',
    mode    => '0444',
    owner   => 'root',
    path    => '/etc/yum.repos.d/10gen.repo'
  }
}
