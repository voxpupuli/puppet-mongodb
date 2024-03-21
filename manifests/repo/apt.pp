# @api private
#
# @summary This is a repo class for apt
#
# @param ensure
#   present or absent
#
# @param repo_location
#   Location of the upstream repository
#
# @param keyring_location
#   Location of the upstream keyring
#
# @param release
#   Specifies a distribution of the Apt repository.
#
# @param repos
#   Specifies a component of the Apt repository.
#
# @param comment
#   Supplies a comment for adding to the Apt source file.
#
class mongodb::repo::apt (
  Enum['present', 'absent'] $ensure,
  String[1] $repo_location,
  String[1] $keyring_location,
  Optional[String[1]] $release = undef,
  Optional[String[1]] $repos = undef,
  Optional[String[1]] $comment = undef,
) {
  # we try to follow/reproduce the instruction
  # from http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

  assert_private()

  include apt

  $keyring_file = split($keyring_location, '/')[-1]
  apt::source { 'mongodb':
    ensure   => $ensure,
    location => $repo_location,
    release  => $mongodb::repo::release,
    repos    => $mongodb::repo::repos,
    key      => {
      dir    => '/usr/share/keyrings/',
      name   => "mongodb-${keyring_file}",
      source => $keyring_location,
    },
    comment  => $comment,
  }

  if($ensure == 'present') {
    Apt::Source['mongodb'] -> Class['apt::update'] -> Package<| tag == 'mongodb_package' |>
  }
}
