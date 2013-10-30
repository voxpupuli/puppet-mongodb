# == Class: mongodb
#
# Manage mongodb installations on RHEL, CentOS, Debian and Ubuntu - either
# installing from the 10Gen repo or from EPEL in the case of EL systems.
#
# === Parameters
#
# enable_10gen (default: false) - Whether or not to set up 10gen software repositories
# init (auto discovered) - override init (sysv or upstart) for Debian derivatives
# location - override apt location configuration for Debian derivatives
# packagename (auto discovered) - override the package name
# servicename (auto discovered) - override the service name
#
# === Examples
#
# To install with defaults from the distribution packages on any system:
#   include mongodb
#
# To install from 10gen on a EL server
#   class { 'mongodb':
#     enable_10gen => true,
#   }
#
# === Authors
#
# Craig Dunn <craig@craigdunn.org>
#
# === Copyright
#
# Copyright 2012 PuppetLabs
#
class mongodb (
  $enable_10gen    = false,
  $init            = $mongodb::params::init,
  $location        = '',
  $packagename     = undef,
  $version         = undef,
  $servicename     = $mongodb::params::service,
  $logpath         = undef,
  $logappend       = true,
  $mongofork       = true,
  $port            = '27017',
  $dbpath          = undef,
  $nojournal       = undef,
  $smallfiles      = undef,
  $cpu             = undef,
  $noauth          = undef,
  $auth            = undef,
  $verbose         = undef,
  $objcheck        = undef,
  $quota           = undef,
  $oplog           = undef,
  $oplog_size      = undef,
  $nohints         = undef,
  $nohttpinterface = undef,
  $noscripting     = undef,
  $notablescan     = undef,
  $noprealloc      = undef,
  $nssize          = undef,
  $mms_token       = undef,
  $mms_name        = undef,
  $mms_interval    = undef,
  $slave           = undef,
  $only            = undef,
  $master          = undef,
  $source          = undef,
  $replset         = undef,
  $rest            = undef,
  $slowms          = undef,
  $keyfile         = undef,
  $bind_ip         = undef
) inherits mongodb::params {

  if $enable_10gen {
    include $mongodb::params::source
    Class[$mongodb::params::source] -> Package['mongodb-10gen']
  }

  if $enable_10gen {
    $mongo_user = $mongodb::params::mongo_user_10gen
    $mongo_group = $mongodb::params::mongo_group_10gen
    $config_path = $mongodb::params::config_path_10gen
  } else {
    $mongo_user = $mongodb::params::mongo_user_os
    $mongo_group = $mongodb::params::mongo_group_os
    $config_path = '/etc/mongodb.conf'
  }

  if $dbpath == undef {
    if $enable_10gen {
      $real_dbpath = $mongodb::params::dbpath_10gen
    } else {
      $real_dbpath = $mongodb::params::dbpath_os
    }
  } else {
    $real_dbpath = $dbpath
  }

  if $logpath == undef {
    if $enable_10gen {
      $real_logpath = $mongodb::params::logpath_10gen
    } else {
      $real_logpath = $mongodb::params::logpath_os
    }
  } else {
    $real_logpath = $logpath
  }

  # NOTE: dirname() not available until stdlib 4.1.0
  $logpath_array = split($real_logpath, '/')
  $logpath_dir_array = delete_at($logpath_array, -1)
  $logpath_dir = join($logpath_dir_array, '/')


  if $packagename {
    $package = $packagename
  } elsif $enable_10gen {
    $package = $mongodb::params::pkg_10gen
  } else {
    $package = $mongodb::params::package
  }

  if $version {
    $ensure_package = $version
  } else {
    $ensure_package = installed
  }

  package { 'mongodb-10gen':
    name   => $package,
    ensure => $ensure_package,
  }

  file { $real_dbpath:
    ensure  => directory,
    owner   => $mongo_user,
    group   => $mongo_group,
    mode    => '0755',
    require => Package['mongodb-10gen']
  }

  file { $logpath_dir:
    ensure  => directory,
    owner   => $mongo_user,
    group   => $mongo_group,
    mode    => '0755',
    require => Package['mongodb-10gen']
  }

  file { $config_path:
    content => template('mongodb/mongodb.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }

  service { 'mongodb':
    name      => $servicename,
    ensure    => running,
    enable    => true,
    subscribe => File[$config_path],
    require   => [File[$real_dbpath], File[$logpath_dir]]
  }
}
