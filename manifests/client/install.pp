# PRIVATE CLASS: do not call directly
class mongodb::client::install {

  $manage_package_repo  = $::mongodb::globals::manage_package_repo
  $version              = $::mongodb::globals::version

  $ensure               = $::mongodb::client::ensure
  $package_name         = $::mongodb::client::package_name

  case $ensure {
    true:     {
      $package_ensure = $version ? {
        undef   => 'present',
        default => $version,
      }
    }
    false:    {
      $package_ensure = 'purged'
    }
    'absent': {
      $package_ensure = 'purged'
    }
    default:  {
      $package_ensure = $ensure
    }
  }

  if $manage_package_repo {
    class { '::mongodb::repo': ensure => $ensure }
  }

  ensure_resource('package', $package_name, {
    ensure  => $package_ensure,
    require => $manage_package_repo ? {
      true    => Anchor['mongodb::repo::end'],
      default => undef,
    }
  })

}
