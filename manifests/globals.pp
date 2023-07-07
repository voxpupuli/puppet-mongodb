# @summary Class for setting cross-class global overrides.
#
# @example  Use a more recent MongoDB version to install from the community repository.
#
#   class {'mongodb::globals':
#     manage_package_repo => true,
#     version             => '3.6',
#   }
#   -> class {'mongodb::client': }
#   -> class {'mongodb::server': }
#
# @example Install MongoDB from a custom repository.
#
#   class {'mongodb::globals':
#      manage_package_repo => true,
#      repo_location       => 'http://example.com/repo'
#   }
#   -> class {'mongodb::server': }
#   -> class {'mongodb::client': }
#
# @example To disable managing of repository, but still enable managing packages.
#
#   class {'mongodb::globals':
#     manage_package_repo => false,
#     manage_package    => true,
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
# @param mongosh_version
#   The version of MonogDB-mongosh to install/manage. This package is mandatory to make this module work.
#   If not specified, the module will use the default for your OS distro.
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
  $server_package_name                   = undef,
  $client_package_name                   = undef,

  $mongod_service_manage                 = undef,
  $service_enable                        = undef,
  $service_ensure                        = undef,
  $service_name                          = undef,
  $service_provider                      = undef,
  $service_status                        = undef,

  $user                                  = undef,
  $group                                 = undef,
  $ipv6                                  = undef,
  $bind_ip                               = undef,
  Optional[String[1]] $version           = undef,
  Optional[Boolean] $manage_package_repo = undef,
  $manage_package                        = undef,
  $repo_proxy                            = undef,
  $proxy_username                        = undef,
  $proxy_password                        = undef,

  $version               = undef,
  $mongosh_version       = undef,
  $manage_package_repo   = fact('os.distro.codename') ? { # Debian 10 doesn't provide mongodb packages. So manage it!
    'buster' => true,
    default  => undef
  },
  $manage_package        = undef,
  $repo_proxy            = undef,
  $proxy_username        = undef,
  $proxy_password        = undef,

  $pidfilepath                           = undef,
  $pidfilemode                           = undef,
  $manage_pidfile                        = undef,
) {
  if $use_enterprise_repo {
    $edition = 'enterprise'
  } else {
    $edition = 'org'
  }

  # Setup of the repo only makes sense globally, so we are doing it here.
  case $facts['os']['family'] {
    'RedHat', 'Linux', 'Suse': {
      # For RedHat, Linux and Suse family: if manage_package_repo is set at undef that include mongodb::repo
      if $manage_package_repo != false {
        class { 'mongodb::repo':
          ensure              => present,
          version             => pick($version, '6.0'),
          use_enterprise_repo => $use_enterprise_repo,
          repo_location       => $repo_location,
          proxy               => $repo_proxy,
        }
      }
    }
    default: {
      # For other (Debian) family: if manage_package_repo is set at undef that not include mongodb::repo
      if $manage_package_repo {
        if $use_enterprise_repo == true and $version == undef {
          fail('You must set mongodb::globals::version when mongodb::globals::use_enterprise_repo is true')
        }

        class { 'mongodb::repo':
          ensure              => present,
          version             => pick($version, '6.0'),
          use_enterprise_repo => $use_enterprise_repo,
          repo_location       => $repo_location,
          proxy               => $repo_proxy,
        }
      }
    }
  }
}
