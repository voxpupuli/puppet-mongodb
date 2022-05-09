# PRIVATE CLASS: do not use directly
class mongodb::repo (
  Variant[Enum['present', 'absent'], Boolean] $ensure = 'present',
  Optional[String] $version                           = undef,
  Boolean $use_enterprise_repo                        = false,
  Optional[String] $repo_location                     = undef,
  Optional[String] $proxy                             = undef,
  Optional[String] $proxy_username                    = undef,
  Optional[String] $proxy_password                    = undef,
  Optional[String[1]] $aptkey_options                 = undef,
) {
  case $facts['os']['family'] {
    'RedHat', 'Linux': {
      if $repo_location != undef {
        $location = $repo_location
        $description = 'MongoDB Custom Repository'
      } elsif $version == undef or versioncmp($version, '3.0.0') < 0 {
        fail('Package repositories for versions older than 3.0 are unsupported')
      } else {
        $mongover = split($version, '[.]')
        if $use_enterprise_repo {
          $location = "https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/${mongover[0]}.${mongover[1]}/\$basearch/"
          $description = 'MongoDB Enterprise Repository'
        } else {
          $location = "https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/${mongover[0]}.${mongover[1]}/\$basearch/"
          $description = 'MongoDB Repository'
        }
      }

      contain mongodb::repo::yum
    }

    'Debian': {
      if $repo_location != undef {
        $location = $repo_location
      } elsif $version == undef or versioncmp($version, '3.0.0') < 0 {
        fail('Package repositories for versions older than 3.0 are unsupported')
      } else {
        if $use_enterprise_repo == true {
          $repo_domain = 'repo.mongodb.com'
          $repo_path   = 'mongodb-enterprise'
        } else {
          $repo_domain = 'repo.mongodb.org'
          $repo_path   = 'mongodb-org'
        }

        $mongover = split($version, '[.]')
        $location = $facts['os']['name'] ? {
          'Debian' => "https://${repo_domain}/apt/debian",
          'Ubuntu' => "https://${repo_domain}/apt/ubuntu",
          default  => undef
        }
        $release     = "${facts['os']['distro']['codename']}/${repo_path}/${mongover[0]}.${mongover[1]}"
        $repos       = $facts['os']['name'] ? {
          'Debian' => 'main',
          'Ubuntu' => 'multiverse',
          default => undef
        }
        $key = "${mongover[0]}.${mongover[1]}" ? {
          '4.2'   => 'E162F504A20CDF15827F718D4B7C549A058F8B6B',
          '4.0'   => '9DA31620334BD75D9DCB49F368818C72E52529D4',
          '3.6'   => '2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5',
          '3.4'   => '0C49F3730359A14518585931BC711F9BA15703C6',
          '3.2'   => '42F3E95A2C4F08279C4960ADD68FA50FEA312927',
          default => '492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10'
        }
        $key_server = 'hkp://keyserver.ubuntu.com:80'
      }

      contain mongodb::repo::apt
    }

    default: {
      if($ensure == 'present' or $ensure == true) {
        fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}, module ${module_name} currently only supports managing repos for osfamily RedHat, Debian and Ubuntu")
      }
    }
  }
}
