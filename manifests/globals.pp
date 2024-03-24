# @summary Class for setting cross-class global overrides.
#
# @example Use a specific MongoDB version to install from the community repository.
#
#   class {'mongodb::globals':
#     manage_package_repo => true,
#     repo_version        => '4.4',
#   }
#   -> class {'mongodb::client': }
#   -> class {'mongodb::server': }
#
# @example Use a specific MongoDB version to install from the enterprise repository.
#
#   class {'mongodb::globals':
#     manage_package_repo => true,
#     repo_version        => '4.4',
#     use_enterprise_repo => true,
#   }
#   -> class {'mongodb::client': }
#   -> class {'mongodb::server': }
#
# @example Use a custom MongoDB apt repository.
#
#   class {'mongodb::globals':
#     manage_package_repo => true,
#     repo_location       => 'https://example.com/repo',
#     keyring_location    => 'https://example.com/keyring.asc'
#   }
#   -> class {'mongodb::client': }
#   -> class {'mongodb::server': }
#
# @example To disable managing of repository, but still enable managing packages.
#
#   class {'mongodb::globals':
#     manage_package_repo => false,
#     manage_package      => true,
#   }
#   -> class {'mongodb::server': }
#   -> class {'mongodb::client': }
#
# @param server_package_name
#   This setting can be used to override the default MongoDB server package name.
#   If not specified, the module will use whatever package name is the default for your OS distro.
#
# @param client_package_name
#   This setting can be used to specify the name of the client package that should be installed.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param mongod_service_manage
#   This setting can be used to override the default management of the mongod service.
#   By default the module will manage the mongod process.
# @param service_enable
#   This setting can be used to specify if the service should be enable at boot
#
# @param service_ensure
#   This setting can be used to specify if the service should be running
#
# @param service_name
#   This setting can be used to override the default MongoDB service name.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param service_provider
#   This setting can be used to override the default MongoDB service provider.
#   If not specified, the module will use whatever service provider is the default for your OS distro.
#
# @param service_status
#   This setting can be used to override the default status check command for your MongoDB service.
#    If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param user
#   This setting can be used to override the default MongoDB user and owner of the service and related files in the file system.
#   If not specified, the module will use the default for your OS distro.
#
# @param group
#   This setting can be used to override the default MongoDB user group to be used for related files in the file system.
#   If not specified, the module will use the default for your OS distro.
#
# @param ipv6
#   This setting is used to configure MongoDB to turn on ipv6 support.
#   If not specified and ipv6 address is passed to MongoDB bind_ip it will just fail.
#
# @param bind_ip
#   This setting can be used to configure MonogDB process to bind to and listen for connections from applications on this address.
#   If not specified, the module will use the default for your OS distro.
#   Note: This value should be passed as an array.
#
# @param version
#   The version of MonogDB to install/manage. This is needed when managing repositories.
#   If not specified, the module will use the default for your OS distro.
#
# @param repo_version
#   The version of the package repo.
#
# @param manage_package_repo
#   Whether to use the MongoDB software repository or the OS packages (True) or a Custom repo (False)
#
# @param manage_package
#   wgether this module willm manage the mongoDB server package
#
# @param repo_proxy
#   This will allow you to set a proxy for your repository in case you are behind a corporate firewall.
#   Currently this is only supported with yum repositories
#
# @param proxy_username
#   This sets the username for the proxyserver, should authentication be required.
#
# @param proxy_password
#   This sets the password for the proxyserver, should authentication be required
#
# @param repo_location
#   This setting can be used to override the default MongoDB repository location.
#   If not specified, the module will use the default repository for your OS distro.
#
# @param keyring_location
#   When `repo_location` is used for an apt repository this setting can be used for the keyring
#   file to download.
#
# @param use_enterprise_repo
#   When manage_package_repo is set to true, this setting indicates if it will use the Community Edition
#   (false, the default) or the Enterprise one (true).
#
# @param pidfilepath
#   Specify a file location to hold the PID or process ID of the mongod process.
#   If not specified, the module will use the default for your OS distro.
#
# @param pidfilemode
#   The file mode of the pid file
#
# @param manage_pidfile
#    If true, the pidfile will be managed by puppet
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
  $keyring_location            = undef,
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
      keyring_location    => $keyring_location,
      proxy               => $repo_proxy,
      proxy_username      => $proxy_username,
      proxy_password      => $proxy_password,
    }
  }
}
