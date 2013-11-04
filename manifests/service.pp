# See README for more details
class mongodb::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  validate_bool($mongodb::service_enable)
  if ! ($mongodb::service_ensure in [ 'running', 'stopped' ]) {
    fail('service_ensure parameter must be running or stopped')
  }

  service { 'mongodb':
    ensure    => $mongodb::service_ensure,
    name      => $mongodb::service_name,
    enable    => $mongodb::service_enable,
  }

}
