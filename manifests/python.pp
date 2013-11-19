# Class: mongodb::python
#
# This class installs the python bindings for mongodb
#
# Parameters:
#   [*package_ensure*] - Ensure state for package. Can be specified as version.
#   [*package_name*]   - Name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#   package { "mongodb::python":
#     require => Package["python-pip"],
#   }
#
class mongodb::python {

  package { "pymongo": 
    ensure   => present,
    provider => pip,
  }
  
}
