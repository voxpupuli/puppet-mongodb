# @api private
#
# @summary This is a repo class for yum
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
# @param proxy
#   Proxy hostnam
#
# @param proxy_username
#   Proxy user name
#
# @param proxy_password
#   Proxy pasword
#
class mongodb::repo::yum (
  Enum['present', 'absent'] $ensure,
  String[1] $repo_location,
  String[1] $description,
  Optional[String[1]] $proxy          = undef,
  Optional[String[1]] $proxy_username = undef,
  Optional[String[1]] $proxy_password = undef,
) {
  # We try to follow/reproduce the instruction
  # https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-red-hat/

  yumrepo { 'mongodb':
    ensure         => $ensure,
    descr          => $description,
    baseurl        => $repo_location,
    gpgcheck       => '0',
    enabled        => '1',
    proxy          => $proxy,
    proxy_username => $proxy_username,
    proxy_password => $proxy_password,
  }
  if $ensure == 'present' {
    Yumrepo['mongodb'] -> Package<| tag == 'mongodb_package' |>
  }
}
