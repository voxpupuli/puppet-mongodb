# PRIVATE CLASS: do not use directly
class mongodb::repo (
  $ensure         = $mongodb::params::ensure,
  $version        = $mongodb::params::version,
  $repo_location  = undef,
  $repo_aptkey    = undef,
  $repo_release   = undef,
  $repo_repos     = undef,
  $proxy          = undef,
  $proxy_username = undef,
  $proxy_password = undef,
) inherits mongodb::params {
  case $::osfamily {
    'RedHat', 'Linux': {
      if ($repo_location != undef){
        $location = $repo_location
        $description = 'MongoDB Custom Repository'
      } elsif $mongodb::globals::use_enterprise_repo == true {
        $location = 'https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/stable/$basearch/'
        $description = 'MongoDB Enterprise Repository'
      }
      elsif (versioncmp($version, '3.0.0') >= 0) {
        $mongover = split($version, '[.]')
        $location = $::architecture ? {
          'x86_64' => "http://repo.mongodb.org/yum/redhat/${::operatingsystemmajrelease}/mongodb-org/${mongover[0]}.${mongover[1]}/x86_64/",
          default  => undef
        }
      }
      else {
        $location = $::architecture ? {
          'x86_64' => 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/',
          'i686'   => 'http://downloads-distro.mongodb.org/repo/redhat/os/i686/',
          'i386'   => 'http://downloads-distro.mongodb.org/repo/redhat/os/i686/',
          default  => undef
        }
        $description = 'MongoDB/10gen Repository'
      }

      class { '::mongodb::repo::yum': }
    }

    'Debian': {
      if ($repo_location != undef){
        $location = $repo_location
        $aptkey = $repos_aptkey
        $release = $repo_release
        $repos = $repo_repos
      }
      else {
        if(versioncmp($version, '3.0.0') >= 0 or $version == undef) {
          $location = $::operatingsystem ? {
            'Debian' => 'http://repo.mongodb.org/apt/debian',
            'Ubuntu' => 'http://repo.mongodb.org/apt/ubuntu',
            default  => undef,
          }
          $aptkey = '42F3E95A2C4F08279C4960ADD68FA50FEA312927'
          if versioncmp($version, '3.1.0') < 0 {
            $release = "${::lsbdistcodename}/mongodb-org/3.0"
          }
          elsif versioncmp($version, '3.2.0') < 0 {
            $release = "${::lsbdistcodename}/mongodb-org/3.1"
          }
          elsif versioncmp($version, '3.3.0') < 0 {
            $release = "${::lsbdistcodename}/mongodb-org/3.2"
          }
          else {
            $release = "${::lsbdistcodename}/mongodb-org/stable"
          }
          $repos = 'multiverse'
        }
        else {
          $location = $::operatingsystem ? {
            'Debian' => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
            'Ubuntu' => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart',
            default  => undef
          }
          $aptkey = '492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10'
          $release = 'dist'
          $repos = '10gen'
        }
      }
      class { '::mongodb::repo::apt': }
    }
    default: {
      if($ensure == 'present' or $ensure == true) {
        fail("Unsupported managed repository for osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports managing repos for osfamily RedHat, Debian and Ubuntu")
      }
    }
  }
}
