# Wrapper class useful for hiera based deployments
# Internal class, do not call directly

class mongodb::replset(
  $sets = undef
) {

  if $sets {
    create_resources(mongodb_replset, $sets)
  }
}
