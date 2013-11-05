# See README for more details
class mongodb::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { 'mongodb':
    ensure => $mongodb::package_ensure,
    name   => $mongodb::real_package_name,
  }

}
