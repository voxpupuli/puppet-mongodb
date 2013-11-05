# See README for details
class mongodb::repo::redhat {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  Class['mongodb::repo::redhat'] -> Class['mongodb::install']

  yumrepo { '10gen':
    descr    => 'MongoDB/10gen Repository',
    baseurl  => $mongodb::repo_location,
    gpgcheck => '0',
    enabled  => '1',
  }

}
