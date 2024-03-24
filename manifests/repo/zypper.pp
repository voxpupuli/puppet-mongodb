# @api private
#
# @summary This is a repo class for zypper
#
# @param ensure
#   present or absent
#
# @param repo_location
#   Location of the upstream repository
#
# @param description
#   A human-readable description of the repository.
#
class mongodb::repo::zypper (
  Enum['present', 'absent'] $ensure,
  String[1] $repo_location,
  String[1] $description,
) {
  # We try to follow/reproduce the instruction
  # https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-suse/

  assert_private()

  zypprepo { 'mongodb':
    ensure   => $ensure,
    descr    => $description,
    baseurl  => $repo_location,
    gpgcheck => '0',
    enabled  => '1',
  }
  if $ensure == 'present' {
    Zypprepo['mongodb'] -> Package<| tag == 'mongodb_package' |>
  }
}
