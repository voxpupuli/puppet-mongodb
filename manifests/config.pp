# See README for more details
class mongodb::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { 'database_path':
    ensure => directory,
    path   => $mongodb::real_dbpath_name,
    owner  => $mongodb::real_user,
    group  => $mongodb::real_group,
    mode   => '0755',
  }

  file { 'logdir_path':
    ensure  => directory,
    path    => $mongodb::logpath_dir,
    owner   => $mongodb::real_user,
    group   => $mongodb::real_group,
    mode    => '0755',
  }

  file { 'config_file':
    ensure  => present,
    path    => $mongodb::config_name,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mongodb/mongodb.conf.erb'),
  }

}
