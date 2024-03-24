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
# @param keyring_location
#   Location of the upstream keyring
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
class mongodb::repo (
  Enum['present', 'absent'] $ensure     = 'present',
  Optional[String] $version             = undef,
  Boolean $use_enterprise_repo          = false,
  Optional[String[1]] $repo_location    = undef,
  Optional[String[1]] $keyring_location = undef,
  Optional[String[1]] $proxy            = undef,
  Optional[String[1]] $proxy_username   = undef,
  Optional[String[1]] $proxy_password   = undef,
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
        $_repo_location = $repo_location
        $description = 'MongoDB Custom Repository'
      } else {
        if $use_enterprise_repo {
          $_repo_location = "https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/${version}/\$basearch/"
          $description = 'MongoDB Enterprise Repository'
        } else {
          $_repo_location = "https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/${version}/\$basearch/"
          $description = 'MongoDB Repository'
        }
      }

      class { 'mongodb::repo::yum':
        ensure         => $ensure,
        repo_location  => $_repo_location,
        description    => $description,
        proxy          => $proxy,
        proxy_username => $proxy_username,
        proxy_password => $proxy_password,
      }
    }

    'Suse': {
      if $repo_location {
        $_repo_location = $repo_location
        $description = 'MongoDB Custom Repository'
      } else {
        if $use_enterprise_repo {
          $_repo_location = "https://repo.mongodb.com/zypper/suse/\$releasever_major/mongodb-enterprise/${version}/\$basearch/"
          $description = 'MongoDB Enterprise Repository'
        } else {
          $_repo_location = "https://repo.mongodb.org/zypper/suse/\$releasever_major/mongodb-org/${version}/\$basearch/"
          $description = 'MongoDB Repository'
        }
      }

      class { 'mongodb::repo::zypper':
        ensure        => $ensure,
        repo_location => $_repo_location,
        description   => $description,
      }
    }

    'Debian': {
      if $repo_location != undef {
        $_repo_location = $repo_location
        $_keyring_location = $keyring_location
      } else {
        if $use_enterprise_repo == true {
          $repo_domain = 'repo.mongodb.com'
          $repo_path   = 'mongodb-enterprise'
        } else {
          $repo_domain = 'repo.mongodb.org'
          $repo_path   = 'mongodb-org'
        }

        $_repo_location = $facts['os']['name'] ? {
          'Debian' => "https://${repo_domain}/apt/debian",
          'Ubuntu' => "https://${repo_domain}/apt/ubuntu",
          default  => undef
        }
        $_keyring_location = "https://www.mongodb.org/static/pgp/server-${version}.asc"
        $release     = "${facts['os']['distro']['codename']}/${repo_path}/${version}"
        $repos       = $facts['os']['name'] ? {
          'Debian' => 'main',
          'Ubuntu' => 'multiverse',
          default => undef
        }
        $comment = 'MongoDB Repository'
      }

      class { 'mongodb::repo::apt':
        ensure           => $ensure,
        repo_location    => $_repo_location,
        keyring_location => $_keyring_location,
        release          => $release,
        repos            => $repos,
        comment          => $comment,
      }
    }

    default: {
      if($ensure == 'present') {
        fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
      }
    }
  }
}
