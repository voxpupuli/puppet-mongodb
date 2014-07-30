# This installs a MongoDB server. See README.md for more details.
class mongodb::server (

  # Global vars
  $user             = $::mongodb::globals::default_user,
  $group            = $::mongodb::globals::default_group,
  $bind_ip          = $::mongodb::globals::default_bind_ip,
  $service_provider = $::mongodb::globals::default_service_provider,

  # NOTE: use of globals is deprecated for the following vars
  $service_status   = $::mongodb::globals::service_status,
  $service_enable   = pick($::mongodb::globals::service_enable, true),
  $service_ensure   = pick($::mongodb::globals::service_ensure, 'running'),

  # Local vars
  $ensure           = true,

  $config           = $::mongodb::server::params::config,
  $dbpath           = $::mongodb::server::params::dbpath,
  $pidfilepath      = $::mongodb::server::params::pidfilepath,

  $service_name     = $::mongodb::server::params::service_name,

  $package_ensure   = true,
  $package_name     = $::mongodb::server::params::package_name,

  $logpath          = $::mongodb::server::params::logpath,
  $logappend        = true,
  $fork             = $::mongodb::server::params::fork,
  $port             = 27017,
  $journal          = $::mongodb::server::params::journal,
  $journal          = $::mongodb::server::params::journal,
  $nojournal        = undef,
  $smallfiles       = undef,
  $cpu              = undef,
  $auth             = false,
  $noauth           = undef,
  $verbose          = undef,
  $verbositylevel   = undef,
  $objcheck         = undef,
  $quota            = undef,
  $quotafiles       = undef,
  $diaglog          = undef,
  $directoryperdb   = undef,
  $profile          = undef,
  $maxconns         = undef,
  $oplog_size       = undef,
  $nohints          = undef,
  $nohttpinterface  = undef,
  $noscripting      = undef,
  $notablescan      = undef,
  $noprealloc       = undef,
  $nssize           = undef,
  $mms_token        = undef,
  $mms_name         = undef,
  $mms_interval     = undef,
  $replset          = undef,
  $rest             = undef,
  $slowms           = undef,
  $keyfile          = undef,
  $set_parameter    = undef,
  $syslog           = undef,

  # Deprecated parameters
  $master           = undef,
  $slave            = undef,
  $only             = undef,
  $source           = undef,

) inherits mongodb::server::params {


  if ($ensure == 'present' or $ensure == true) {
    anchor { 'mongodb::server::start': }->
    class { 'mongodb::server::install': }->
    class { 'mongodb::server::config': }->
    class { 'mongodb::server::service': }->
    anchor { 'mongodb::server::end': }
  } else {
    anchor { 'mongodb::server::start': }->
    class { 'mongodb::server::service': }->
    class { 'mongodb::server::config': }->
    class { 'mongodb::server::install': }->
    anchor { 'mongodb::server::end': }
  }
}
