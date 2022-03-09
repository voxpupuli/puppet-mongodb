# Class for setting cross-class global overrides. See README.md for more
# details.
class mongodb::globals (
  $server_package_name   = undef,
  $client_package_name   = undef,

  $mongod_service_manage = undef,
  $service_enable        = undef,
  $service_ensure        = undef,
  $service_name          = undef,
  $service_provider      = undef,
  $service_status        = undef,

  $user                  = undef,
  $group                 = undef,
  $ipv6                  = undef,
  $bind_ip               = undef,

  $version               = fact('os.distro.codename') ? { # Debian 10 doesn't provide mongodb 3.6.
    'buster' => '4.4.8',
    default  => undef
  },
  $manage_package_repo   = fact('os.distro.codename') ? { # Debian 10 doesn't provide mongodb packages. So manage it!
    'buster' => true,
    default  => undef
  },
  $manage_package        = undef,
  $repo_proxy            = undef,
  $proxy_username        = undef,
  $proxy_password        = undef,

  $repo_location         = undef,
  $use_enterprise_repo   = undef,

  $pidfilepath           = undef,
  $pidfilemode           = undef,
  $manage_pidfile        = undef,
) {
  if $use_enterprise_repo {
    $edition = 'enterprise'
  } else {
    $edition = 'org'
  }

  # Setup of the repo only makes sense globally, so we are doing it here.
  if $manage_package_repo {
    case $facts['os']['family'] {
      'RedHat', 'Linux', 'Suse': {
        class { 'mongodb::repo':
          ensure              => present,
          version             => pick($version, '3.6'),
          use_enterprise_repo => $use_enterprise_repo,
          repo_location       => $repo_location,
          proxy               => $repo_proxy,
        }
      }
      default: {
        if $use_enterprise_repo == true and $version == undef {
          fail('You must set mongodb::globals::version when mongodb::globals::use_enterprise_repo is true')
        }

        class { 'mongodb::repo':
          ensure              => present,
          version             => $version,
          use_enterprise_repo => $use_enterprise_repo,
          repo_location       => $repo_location,
          proxy               => $repo_proxy,
        }
      }
    }
  }
}
