# @summary Wrapper class useful for hiera based deployments
#
# @example hieradata
#
#  mongodb::replset::sets:
#    replicaset01:
#      ensure: present
#      members:
#        - member01.example.com:27017
#        - member02.example.com:27017
#        - member03.example.com:27017
#
# @param sets
#    Hash of attributes as described in the mongodb_replset custom type
#
class mongodb::replset (
  $sets = undef
) {
  if $sets {
    create_resources(mongodb_replset, $sets)
  }

  # Order replset before any DB's and shard config
  Mongodb_replset <| |> -> Mongodb_database <| |>
  Mongodb_replset <| |> -> Mongodb_shard <| |>
  Mongodb_replset <| |> -> Mongodb_user <| |>
}
