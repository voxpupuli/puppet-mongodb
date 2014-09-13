# Wrapper class useful for hiera based deployments
#
# Direct use of this class is deprecated. Please use the $::mongodb::server::replsets parameter
#

class mongodb::replset(
  $sets = undef
) {

  if $sets {
    create_resources(mongodb_replset, $sets)
  }

  notify { 'Direct use of the mongodb::replset class is deprecated. Please use the $::mongodb::server::replsets parameter':
    loglevel => warning,
  }

}

