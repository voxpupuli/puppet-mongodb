# @summary Class for setting cross-class global overrides. See README.md for more details.
#
# @param server_package_name
# @param client_package_name
# @param mongod_service_manage
# @param service_enable
# @param service_ensure
# @param service_name
# @param service_provider
# @param service_status
# @param user
# @param group
# @param ipv6
# @param bind_ip
# @param version Version of mongodb to install
# @param repo_version Version of mongodb repo to install
# @param manage_package_repo If `true` configure upstream mongodb repos
# @param manage_package
# @param repo_proxy
# @param proxy_username
# @param proxy_password
# @param repo_location
# @param use_enterprise_repo
# @param pidfilepath
# @param pidfilemode
# @param manage_pidfile
#
class mongodb::globals (
  $server_package_name         = undef,
  $client_package_name         = undef,

  $mongod_service_manage       = undef,
  $service_enable              = undef,
  $service_ensure              = undef,
  $service_name                = undef,
  $service_provider            = undef,
  $service_status              = undef,

  $user                        = undef,
  $group                       = undef,
  $ipv6                        = undef,
  $bind_ip                     = undef,
  Optional[String[1]] $version = undef,
  String[1] $repo_version      = '5.0',
  Boolean $manage_package_repo = true,
  $manage_package              = undef,
  $repo_proxy                  = undef,
  $proxy_username              = undef,
  $proxy_password              = undef,

  $repo_location               = undef,
  $use_enterprise_repo         = undef,

  $pidfilepath                 = undef,
  $pidfilemode                 = undef,
  $manage_pidfile              = undef,
) {
  if $use_enterprise_repo {
    $edition = 'enterprise'
  } else {
    $edition = 'org'
  }

  # Setup of the repo only makes sense globally, so we are doing it here.
  if $manage_package_repo {
    class { 'mongodb::repo':
      ensure              => present,
      version             => $repo_version,
      use_enterprise_repo => $use_enterprise_repo,
      repo_location       => $repo_location,
      proxy               => $repo_proxy,
    }
  }
}
