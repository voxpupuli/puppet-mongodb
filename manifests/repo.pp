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

    'Suse': {
      if $repo_location {
        $location = $repo_location
        $description = 'MongoDB Custom Repository'
      } elsif $version == undef or versioncmp($version, '3.2.0') < 0 {
        fail('Package repositories for versions older than 3.2 are unsupported')
      } else {
        $mongover = split($version, '[.]')
        $location = "https://repo.mongodb.org/zypper/suse/\$releasever_major/mongodb-org/${mongover[0]}.${mongover[1]}/\$basearch/"
        $description = 'MongoDB Repository'
      }

      contain mongodb::repo::zypper
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
        $release     = "buster/${repo_path}/${mongover[0]}.${mongover[1]}"
        $repos       = $facts['os']['name'] ? {
          'Debian' => 'main',
          'Ubuntu' => 'multiverse',
          default => undef
        }
        $key = "${mongover[0]}.${mongover[1]}" ? {
          '5.0'   => 'F5679A222C647C87527C2F8CB00A0BD1E2C63C11',
          '4.4'   => '20691EEC35216C63CAF66CE1656408E390CFB1F5',
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
        fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}, module ${module_name} currently only supports managing repos for osfamily RedHat, Suse, Debian and Ubuntu")
      }
    }
  }
}
