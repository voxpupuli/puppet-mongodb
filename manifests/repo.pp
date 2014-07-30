# PRIVATE CLASS: do not use directly
class mongodb::repo (

  $ensure  = undef,

) {

  $url_prefix = 'http://downloads-distro.mongodb.org/repo'

  case $::osfamily {
    'RedHat', 'Linux': {
      $location = $::architecture ? {
        'x86_64' => "${url_prefix}/redhat/os/x86_64/",
        'i686'   => "${url_prefix}/redhat/os/i686/",
        'i386'   => "${url_prefix}/redhat/os/i686/",
        default  => undef
      }

      anchor  { 'mongodb::repo::start': } ->
      class   { 'mongodb::repo::yum':   } ->
      anchor  { 'mongodb::repo::end':   }

    }

    'Debian': {
      $location = $::operatingsystem ? {
        'Debian' => "${url_prefix}/debian-sysvinit",
        'Ubuntu' => "${url_prefix}/ubuntu-upstart",
        default  => undef
      }

      anchor  { 'mongodb::repo::start': } ->
      class   { 'mongodb::repo::apt':   } ->
      anchor  { 'mongodb::repo::end':   }

    }

    default: {
      if($ensure == 'present' or $ensure == true) {
        fail("Unsupported managed repository for osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports managing repos for osfamily RedHat, Debian and Ubuntu")
      }
    }
  }

}
