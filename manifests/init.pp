# == Class: mongodb
#
# Manage mongodb installations on RHEL, CentOS, Debian and Ubuntu - either
# installing from the 10Gen repo or from EPEL in the case of EL systems.
#
# === Parameters
#
# setup_sources (default: true) - Whether or not to set up software sources in yum/apt
# init (auto discovered) - override init (sysv or upstart) for Debian derivitives
# packagename (auto discovered) - override the package name (eg: for EPEL)
# servicename (auto discovered) - override the service name 
#
# === Examples
#
# To install with defaults from sources on any system:
#   include mongodb
#
# To install from EPEL on a EL server
#   class { 'mongodb':
#     setup_sources => false,
#     packagename   => 'mongodb-server',
#   }
#
# === Authors
#
# Craig Dunn <craig@craigdunn.org>
#
# === Copyright
#
# Copyright 2011 Craig Dunn
#
class mongodb (
  $setup_sources   = true,
  $init            = $mongodb::params::init,
  $location        = '',
  $packagename     = $mongodb::params::package,
  $servicename     = $mongodb::params::service,
  $logpath         = '/var/log/mongo/mongod.log',
  $logappend       = 'true',
  $mongofork       = 'true',
  $port            = '27017',
  $dbpath          = '/var/lib/mongo',
  $nojournal       = undef,
  $cpu             = undef,
  $noauth          = undef,
  $auth            = undef,
  $verbose         = undef,
  $objcheck        = undef,
  $quota           = undef,
  $oplog           = undef,
  $nohints         = undef,
  $nohttpinterface = undef,
  $noscripting     = undef,
  $notablescan     = undef,
  $noprealloc      = undef,
  $nssize          = undef,
  $mms_token       = undef,
  $mms_name        = undef,
  $mms_name        = undef,
  $mms_interval    = undef,
  $slave           = undef,
  $only            = undef,
  $master          = undef,
  $source          = undef
) inherits mongodb::params {

  if $setup_sources {
    include $mongodb::params::source
    Class[$mongodb::params::source] -> Package['mongodb-10gen']
  }

  package { 'mongodb-10gen':
    name   => $packagename,
    ensure => installed,
  }

  file { '/etc/mongod.conf':
    content => template('mongodb/mongod.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mongodb-10gen'],
  }

  service { 'mongodb':
    name      => $servicename,
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/mongod.conf'],
  }
}
