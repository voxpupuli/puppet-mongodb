# @api private
#
# @summary Private clas to manage the mongodb repo
#
# @param ensure
#   present or absent
#
# @param version
#   The version of the mongodb repo
#
# @param use_enterprise_repo
#   Wether to use the OS or Enterprise repo
#
# @param repo_location
#   Location of the upstream repository
#
# @param proxy
#   Proxy hostnam
#
# @param proxy_username
#   Proxy user name
#
# @param proxy_password
#   Proxy pasword
#
# @param aptkey_options
#   Options for debian aptkey
#
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
      } elsif $version == undef or versioncmp($version, '4.4.0') < 0 {
        fail('Package repositories for versions older than 4.4 are unsupported')
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
      } elsif $version == undef or versioncmp($version, '4.4.0') < 0 {
        fail('Package repositories for versions older than 4.4 are unsupported')
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
      } elsif $version == undef or versioncmp($version, '4.4.0') < 0 {
        fail('Package repositories for versions older than 4.4 are unsupported')
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
          '7.0'   => 'E58830201F7DD82CD808AA84160D26BB1785BA38',
          '6.0'   => '39BD841E4BE5FB195A65400E6A26B1AE64C3C388',
          '5.0'   => 'F5679A222C647C87527C2F8CB00A0BD1E2C63C11',
          '4.8'   => '1283B7BB8CF331A5BE0E1E100EBB00BA3BC3DCCB',
          '4.6'   => '99DC630F00A2F97F27C6A02A253612A09571B484',
          '4.4'   => '20691EEC35216C63CAF66CE1656408E390CFB1F5',
          default => '492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10'
        }
        $key_server = 'hkp://keyserver.ubuntu.com:80'
      }

      contain mongodb::repo::apt
    }

    default: {
      if($ensure == 'present' or $ensure == true) {
        fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}, module ${module_name} currently only supports managing repos for osfamily RedHat, Suse, Debian and Ubuntu") # lint:ignore:140chars
      }
    }
  }
}
