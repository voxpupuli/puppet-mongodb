# PRIVATE CLASS: do not call directly
class mongodb::server::install {

  $manage_package_repo  = $::mongodb::globals::manage_package_repo
  $version              = $::mongodb::globals::version

  $ensure               = $::mongodb::server::ensure
  $package_ensure       = $::mongodb::server::package_ensure
  $package_name         = $::mongodb::server::package_name

  # use $package_ensure override
  if $package_ensure != undef {
    case $package_ensure {
      true:     {
        $my_package_ensure = $version ? {
          undef   => 'present',
          default => $version,
        }
      }
      false:    { $my_package_ensure  = 'absent'        }
      'absent': { $my_package_ensure  = 'absent'        }
      'purged': { $my_package_ensure  = 'purged'        }
      default:  { $my_package_ensure  = $package_ensure }
    }

  # use $ensure
  } else {
    case $ensure {
      true:     {
        $my_package_ensure = $version ? {
          undef   => 'present',
          default => $version,
        }
      }
      false:    { $my_package_ensure  = 'absent'  }
      'absent': { $my_package_ensure  = 'absent'  }
      'purged': { $my_package_ensure  = 'purged'  }
      default:  { $my_package_ensure  = $ensure   }
    }
  }

  case $my_package_ensure {
    true:     { $file_ensure = 'directory'  }
    false:    { $file_ensure = 'absent'     }
    'absent': { $file_ensure = 'absent'     }
    'purged': { $file_ensure = 'absent'     }
    default:  { $file_ensure = 'present'    }
  }

  if $manage_package_repo {
    class { '::mongodb::repo': ensure => $my_package_ensure }
  }

  ensure_resource('package', $package_name, {
    ensure  => $my_package_ensure,
    require => $manage_package_repo ? {
      true    => Anchor['mongodb::repo::end'],
      default => undef,
    }
  })
}
