# See README for more details.
class mongodb (
  $auth            = $mongodb::params::auth,
  $bind_ip         = undef,
  $config_path     = undef,
  $cpu             = $mongodb::params::cpu,
  $dbpath          = undef,
  $enable_10gen    = $mongodb::params::enable_10gen,
  $fork            = undef,
  $init            = $mongodb::params::init,
  $journal         = undef,
  $keyfile         = $mongodb::params::keyfile,
  $location        = $mongodb::params::location,
  $logappend       = $mongodb::params::logappend,
  $logpath         = undef,
  $master          = $mongodb::params::master,
  $mongo_group     = undef,
  $mongo_user      = undef,
  $mms_interval    = $mongodb::params::mms_interval,
  $mms_name        = $mongodb::params::mms_name,
  $mms_token       = $mongodb::params::mms_token,
  $noauth          = $mongodb::params::noauth,
  $nohints         = $mongodb::params::nohints,
  $nohttpinterface = $mongodb::params::nohttpinterface,
  $nojournal       = $mongodb::params::nojournal,
  $noprealloc      = $mongodb::params::noprealloc,
  $noscripting     = $mongodb::params::noscripting,
  $notablescan     = $mongodb::params::notablescan,
  $nssize          = $mongodb::params::nssize,
  $objcheck        = $mongodb::params::objcheck,
  $only            = $mongodb::params::only,
  $oplog           = $mongodb::params::oplog,
  $oplog_size      = $mongodb::params::oplog_size,
  $packagename     = undef,
  $pidfilepath     = undef,
  $port            = $mongodb::params::port,
  $quota           = $mongodb::params::quota,
  $replset         = $mongodb::params::replset,
  $rest            = $mongodb::params::rest,
  $service_enable  = $mongodb::params::service_enable,
  $servicename     = $mongodb::params::servicename,
  $slave           = $mongodb::params::slave,
  $slowms          = $mongodb::params::slowms,
  $smallfiles      = $mongodb::params::smallfiles,
  $source          = $mongodb::params::source,
  $verbose         = $mongodb::params::verbose,
  $version         = $mongodb::params::version
) inherits mongodb::params {

  if $enable_10gen {
    include $mongodb::params::source
    Class[$mongodb::params::source] -> Package['mongodb-10gen']
  }

  # Pick() only works if at least one value is positive, so we wrap some in
  # if tests.
  if $enable_10gen {
    if $mongodb::params::default_bind_ip_10gen {
      $_bind_ip = pick($bind_ip, $mongodb::params::default_bind_ip_10gen)
    } else {
      $_bind_ip = $bind_ip
    }
    $_config_path = pick($config_path, $mongodb::params::config_path_10gen)
    $_dbpath      = pick($dbpath, $mongodb::params::default_dbpath_10gen)
    if $mongodb::params::default_fork_10gen {
      $_fork      = pick($fork, $mongodb::params::default_fork_10gen)
    } else {
      $_fork      = $fork
    }
    if $mongodb::params::default_journal_10gen {
      $_journal   = pick($journal, $mongodb::params::default_journal_10gen)
    } else {
      $_journal   = $journal
    }
    $_logpath     = pick($logpath, $mongodb::params::default_logpath_10gen)
    $_mongo_group = pick($mongo_group, $mongodb::params::mongo_group_10gen)
    $_mongo_user  = pick($mongo_user, $mongodb::params::mongo_user_10gen)
    $_packagename = pick($packagename, $mongodb::params::pkg_10gen)
    if $mongodb::params::default_pidfilepath_10gen {
      $_pidfilepath = pick($pidfilepath, $mongodb::params::default_pidfilepath_10gen)
    } else {
      $_pidfilepath = $pidfilepath
    }
  } else {
    $_bind_ip     = pick($bind_ip, $mongodb::params::default_bind_ip)
    $_config_path = pick($config_path, '/etc/mongodb.conf')
    $_dbpath      = pick($dbpath, $mongodb::params::default_dbpath)
    if $mongodb::params::default_fork {
      $_fork      = pick($fork, $mongodb::params::default_fork)
    } else {
      $_fork      = $fork
    }
    $_journal     = pick($journal, $mongodb::params::default_journal)
    $_logpath     = pick($logpath, $mongodb::params::default_logpath)
    $_mongo_group = pick($mongo_group, $mongodb::params::mongo_group_os)
    $_mongo_user  = pick($mongo_user, $mongodb::params::mongo_user_os)
    $_packagename = pick($packagename, $mongodb::params::package)
    if $mongodb::params::default_pidfilepath_10gen {
      $_pidfilepath = pick($pidfilepath, $mongodb::params::default_pidfilepath)
    } else {
      $_pidfilepath = $pidfilepath
    }
  }

  # NOTE: dirname() not available until stdlib 4.1.0
  $logpath_array = split($_logpath, '/')
  $logpath_dir_array = delete_at($logpath_array, -1)
  $logpath_dir = join($logpath_dir_array, '/')

  package { 'mongodb-10gen':
    ensure => $version,
    name   => $_packagename,
  }

  file { $_dbpath:
    ensure  => directory,
    owner   => $_mongo_user,
    group   => $_mongo_group,
    mode    => '0755',
    require => Package['mongodb-10gen']
  }

  file { $logpath_dir:
    ensure  => directory,
    owner   => $_mongo_user,
    group   => $_mongo_group,
    mode    => '0755',
    require => Package['mongodb-10gen']
  }

  file { $_config_path:
    content => template('mongodb/mongodb.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }

  validate_bool($service_enable)
  if $service_enable {
    $service_ensure = 'running'
    $service_subscribe = File[$_config_path]
  } else {
    $service_ensure = 'stopped'
    $service_subscribe = undef
  }

  service { 'mongodb':
    ensure    => $service_ensure,
    name      => $servicename,
    enable    => $service_enable,
    subscribe => $service_subscribe,
    require   => [File[$_dbpath], File[$logpath_dir]]
  }
}
