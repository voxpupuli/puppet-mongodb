# @summary Manages mongod config
#
# @api private
#
class mongodb::server::config {
  $ensure           = $mongodb::server::ensure
  $user             = $mongodb::server::user
  $group            = $mongodb::server::group
  $system_log_config = $mongodb::server::system_log_config
  $process_management_config = $mongodb::server::process_management_config
  $net_config = $mongodb::server::net_config
  $config           = $mongodb::server::config
  $config_content   = $mongodb::server::config_content
  $config_template  = $mongodb::server::config_template
  $config_data      = $mongodb::server::config_data
  $dbpath           = $mongodb::server::dbpath
  $dbpath_fix       = $mongodb::server::dbpath_fix
  $journal          = $mongodb::server::journal
  $smallfiles       = $mongodb::server::smallfiles
  $cpu              = $mongodb::server::cpu
  $auth             = $mongodb::server::auth
  $create_admin     = $mongodb::server::create_admin
  $admin_username   = $mongodb::server::admin_username
  $admin_password   = $mongodb::server::admin_password
  $handle_creds     = $mongodb::server::handle_creds
  $store_creds      = $mongodb::server::store_creds
  $rcfile           = $mongodb::server::rcfile
  $quota            = $mongodb::server::quota
  $quotafiles       = $mongodb::server::quotafiles
  $diaglog          = $mongodb::server::diaglog
  $oplog_size       = $mongodb::server::oplog_size
  $nohints          = $mongodb::server::nohints
  $noscripting      = $mongodb::server::noscripting
  $notablescan      = $mongodb::server::notablescan
  $noprealloc       = $mongodb::server::noprealloc
  $nssize           = $mongodb::server::nssize
  $mms_token        = $mongodb::server::mms_token
  $mms_name         = $mongodb::server::mms_name
  $mms_interval     = $mongodb::server::mms_interval
  $configsvr        = $mongodb::server::configsvr
  $shardsvr         = $mongodb::server::shardsvr
  $replset          = $mongodb::server::replset
  $quiet            = $mongodb::server::quiet
  $slowms           = $mongodb::server::slowms
  $keyfile          = $mongodb::server::keyfile
  $key              = $mongodb::server::key
  $directoryperdb   = $mongodb::server::directoryperdb
  $profile          = $mongodb::server::profile
  $set_parameter    = $mongodb::server::set_parameter
  $storage_engine   = $mongodb::server::storage_engine

  File {
    owner => $user,
    group => $group,
  }

  if ($ensure == 'present' or $ensure == true) {
    if $keyfile and $key {
      file { $keyfile:
        content => $key,
        owner   => $user,
        group   => $group,
        mode    => '0400',
      }
    }

    if empty($storage_engine) {
      $storage_engine_internal = undef
    } else {
      $storage_engine_internal = $storage_engine
    }

    # Pick which config content to use
    if $config_content {
      $cfg_content = $config_content
    } elsif $config_template {
      # Template has available user-supplied data
      # - $config_data
      $cfg_content = template($config_template)
    } else {
      # Template has available user-supplied data
      # - $config_data
      $cfg_content = template('mongodb/mongodb.conf.erb')
    }

    file { $config:
      content => $cfg_content,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    file { $dbpath:
      ensure   => directory,
      mode     => '0750',
      owner    => $user,
      group    => $group,
      selrange => 's0',
      selrole  => 'object_r',
      seltype  => 'mongod_var_lib_t',
      seluser  => 'system_u',
      require  => File[$config],
    }

    if $dbpath_fix {
      exec { 'fix dbpath permissions':
        command   => "chown -R ${user}:${group} ${dbpath}",
        path      => ['/usr/bin', '/bin'],
        onlyif    => "find ${dbpath} -not -user ${user} -o -not -group ${group} -print -quit | grep -q '.*'",
        subscribe => File[$dbpath],
      }
    }
  } else {
    file { $dbpath:
      ensure => absent,
      force  => true,
      backup => false,
    }
    file { $config:
      ensure => absent,
    }
  }

  $admin_password_unsensitive = if $admin_password =~ Sensitive[String] {
    $admin_password.unwrap
  } else {
    $admin_password
  }
  if $handle_creds {
    file { $rcfile:
      ensure  => file,
      content => template('mongodb/mongoshrc.js.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    }
  }
}
