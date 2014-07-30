# PRIVATE CLASS: do not call directly
class mongodb::server::install {

  $manage_package_repo  = $::mongodb::globals::manage_package_repo
  $version              = $::mongodb::globals::version

  $package_ensure       = $::mongodb::server::package_ensure
  $package_name         = $::mongodb::server::package_name

  case $package_ensure {
    true:     {
      $my_package_ensure = $version ? {
        undef   => 'present',
        default => $version,
      }
      $file_ensure        = 'directory'
    }
    false:    {
      $my_package_ensure  = 'absent'
      $file_ensure        = 'absent'
    }
    'absent': {
      $my_package_ensure  = 'absent'
      $file_ensure        = 'absent'
    }
    'purged': {
      $my_package_ensure  = 'purged'
      $file_ensure        = 'absent'
    }
    default:  {
      $my_package_ensure  = $package_ensure
      $file_ensure        = 'present'
    }
  }

  if $manage_package_repo {
    class { '::mongodb::repo': ensure => $package_ensure }
  }

  ensure_resource('package', $package_name, {
    ensure  => $my_package_ensure,
    require => $manage_package_repo ? {
      true    => Anchor['mongodb::repo::end'],
      default => undef,
    }
  })
}
