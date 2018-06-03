# PRIVATE CLASS: do not call directly
class mongodb::tools::install {
  $package_ensure = $mongodb::tools::ensure
  $package_name   = $mongodb::tools::package_name

  case $package_ensure {
    true:     {
      $my_package_ensure = 'present'
    }
    false:    {
      $my_package_ensure = 'purged'
    }
    'absent': {
      $my_package_ensure = 'purged'
    }
    default:  {
      $my_package_ensure = $package_ensure
    }
  }

  if $package_name {
    package { 'mongodb_tools':
      ensure => $my_package_ensure,
      name   => $package_name,
      tag    => 'mongodb',
    }
  }
}
