# See README for more details.
class mongodb (
  $type            = 'distro',
  $auth            = $mongodb::params::auth,
  $bind_ip         = $mongodb::params::bind_ip,
  $config_name     = $mongodb::params::config_name,
  $cpu             = $mongodb::params::cpu,
  $dbpath_name     = $mongodb::params::dbpath_name['distro'],
  $fork            = $mongodb::params::fork,
  $group           = $mongodb::params::group['distro'],
  $init            = $mongodb::params::init,
  $journal         = $mongodb::params::journal,
  $keyfile         = $mongodb::params::keyfile,
  $repo_location   = $mongodb::params::repo_location,
  $logappend       = $mongodb::params::logappend,
  $logpath_name    = $mongodb::params::logpath_name['distro'],
  $master          = $mongodb::params::master,
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
  $package_ensure  = $mongodb::params::package_ensure,
  $package_name    = $mongodb::params::package_name['distro'],
  $pidfilepath     = $mongodb::params::pidfilepath['distro'],
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
  $user            = $mongodb::params::user['distro'],
  $verbose         = $mongodb::params::verbose,
) inherits mongodb::params {

  if $type == '10gen' {
    $real_dbpath_name  = $mongodb::params::dbpath_name['10gen']
    $real_group        = $mongodb::params::group['10gen']
    $real_logpath_name = $mongodb::params::logpath_name['10gen']
    $real_package_name = $mongodb::params::package_name['10gen']
    $real_pidfilepath  = $mongodb::params::pidfilepath['10gen']
    $real_user         = $mongodb::params::user['10gen']
  } else {
    $real_dbpath_name  = $dbpath_name
    $real_group        = $group
    $real_logpath_name = $logpath_name
    $real_package_name = $package_name
    $real_pidfilepath  = $pidfilepath
    $real_user         = $user
  }

  $logpath_dir = dirname($real_logpath_name)

  if $type == '10gen' {
    if ($::osfamily in [ 'RedHat', 'Debian' ]) {
      include downcase("mongodb::repo::${::osfamily}")
    } else {
      fail("10gen repos are unsupported on ${::osfamily}")
    }
  }

  

  anchor { 'mongodb::start': } ->
    class { 'mongodb::install': } ->
    class { 'mongodb::config': } ~>
    class { 'mongodb::service': } ->
  anchor { 'mongodb::end': }

}
