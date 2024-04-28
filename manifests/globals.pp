# @summary Class for setting cross-class global overrides.
#
# @example Use a specific MongoDB version to install from the community repository.
#
#   class {'mongodb::globals':
#     manage_package_repo => true,
#     repo_version        => '6.0',
#   }
#   -> class {'mongodb::client': }
#   -> class {'mongodb::server': }
#
# @example Use a specific MongoDB version to install from the enterprise repository.
#
#   class {'mongodb::globals':
#     manage_package_repo => true,
#     repo_version        => '6.0',
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
#   }
#   -> class {'mongodb::server': }
#   -> class {'mongodb::client': }
#
# @param version
#   The version of MonogDB to install/manage.
#   If not specified, the module will ensure packages with `present`.
#
# @param client_version
#   The version of MongoDB Shell to install/manage.
#   If not specified, the module will ensure packages with `present`.
#
# @param manage_package_repo
#   Whether to manage MongoDB software repository.
#
# @param repo_version
#   The version of the package repo.
#
# @param use_enterprise_repo
#   When manage_package_repo is set to true, this setting indicates if it will use the Community Edition
#   (false, the default) or the Enterprise one (true).
#
# @param repo_location
#   This setting can be used to override the default MongoDB repository location.
#   If not specified, the module will use the default repository for your OS distro.
#
# @param repo_proxy
#   This will allow you to set a proxy for your repository in case you are behind a corporate firewall.
#   Currently this is only supported with yum repositories
#
# @param keyring_location
#   When `repo_location` is used for an apt repository this setting can be used for the keyring
#   file to download.
#
# @param proxy_username
#   This sets the username for the proxyserver, should authentication be required.
#
# @param proxy_password
#   This sets the password for the proxyserver, should authentication be required
#
class mongodb::globals (
  Optional[String[1]] $version        = undef,
  Optional[String[1]] $client_version = undef,
  Boolean $manage_package_repo        = true,
  String[1] $repo_version             = '5.0',
  Boolean $use_enterprise_repo        = false,
  Optional[String] $repo_location     = undef,
  Optional[String] $keyring_location  = undef,
  Optional[String] $repo_proxy        = undef,
  Optional[String] $proxy_username    = undef,
  Optional[String] $proxy_password    = undef,
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
