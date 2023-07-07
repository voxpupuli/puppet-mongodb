# @api private
#
# @summary Manages the mongodb repository
#
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
  Enum['present', 'absent'] $ensure   = 'present',
  Optional[String] $version           = undef,
  Boolean $use_enterprise_repo        = false,
  Optional[String] $repo_location     = undef,
  Optional[String] $proxy             = undef,
  Optional[String] $proxy_username    = undef,
  Optional[String] $proxy_password    = undef,
  Optional[String[1]] $aptkey_options = undef,
) {
  if $version == undef and $repo_location == undef {
    fail('`version` or `repo_location` is required')
  }
  if $version != undef and $repo_location != undef {
    fail('`version` is not supported with `repo_location`')
  }
  if $version != undef and versioncmp($version, '4.4') < 0 {
    fail('Package repositories for versions older than 4.4 are unsupported')
  }

  case $facts['os']['family'] {
    'RedHat', 'Linux': {
      if $repo_location != undef {
        $location = $repo_location
        $description = 'MongoDB Custom Repository'
      } else {
        if $use_enterprise_repo {
          $location = "https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/${version}/\$basearch/"
          $description = 'MongoDB Enterprise Repository'
        } else {
          $location = "https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/${version}/\$basearch/"
          $description = 'MongoDB Repository'
        }
      }

      contain mongodb::repo::yum
    }

    'Suse': {
      if $repo_location {
        $location = $repo_location
        $description = 'MongoDB Custom Repository'
      } else {
        $location = "https://repo.mongodb.org/zypper/suse/\$releasever_major/mongodb-org/${version}/\$basearch/"
        $description = 'MongoDB Repository'
      }

      contain mongodb::repo::zypper
    }

    'Debian': {
      if $repo_location != undef {
        $location = $repo_location
      } else {
        if $use_enterprise_repo == true {
          $repo_domain = 'repo.mongodb.com'
          $repo_path   = 'mongodb-enterprise'
        } else {
          $repo_domain = 'repo.mongodb.org'
          $repo_path   = 'mongodb-org'
        }

        $location = $facts['os']['name'] ? {
          'Debian' => "https://${repo_domain}/apt/debian",
          'Ubuntu' => "https://${repo_domain}/apt/ubuntu",
          default  => undef
        }
        $release     = "${facts['os']['distro']['codename']}/${repo_path}/${version}"
        $repos       = $facts['os']['name'] ? {
          'Debian' => 'main',
          'Ubuntu' => 'multiverse',
          default => undef
        }
        $key = $version ? {
          '5.0'   => 'F5679A222C647C87527C2F8CB00A0BD1E2C63C11',
          '4.4'   => '20691EEC35216C63CAF66CE1656408E390CFB1F5',
          default => '20691EEC35216C63CAF66CE1656408E390CFB1F5'
        }
        $key_server = 'hkp://keyserver.ubuntu.com:80'
      }

      contain mongodb::repo::apt
    }

    default: {
      if($ensure == 'present') {
        fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}, module ${module_name} currently only supports managing repos for osfamily RedHat, Suse, Debian and Ubuntu")
      }
    }
  }
}
