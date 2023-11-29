#
# @summary Wrapper class useful for hiera based deployments
#
# @param sets_creation
#   Boolean to disable mongodb_replset resource, we can use it to skipt this on Arbiter nodes that will produce an error when enabled
# @param sets
#   Hash containing the replica set config
#
class mongodb::replset (
  Boolean        $sets_creation = true,
  Optional[Hash] $sets          = undef,
) {
  if $sets and $sets_creation {
    create_resources(mongodb_replset, $sets)
  }

  # Order replset before any DB's and shard config
  Mongodb_replset <| |> -> Mongodb_database <| |>
  Mongodb_replset <| |> -> Mongodb_shard <| |>
  Mongodb_replset <| |> -> Mongodb_user <| |>
}
