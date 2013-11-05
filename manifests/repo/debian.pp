# See README for details
class mongodb::repo::debian {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  include apt
  Class['mongodb::repo::debian'] -> Class['mongodb::install']

  apt::source { '10gen':
    location    => $mongodb::repo_location,
    release     => 'dist',
    repos       => '10gen',
    key         => '7F0CEB10',
    key_server  => 'keyserver.ubuntu.com',
    include_src => false,
  }

}
