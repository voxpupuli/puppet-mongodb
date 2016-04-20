# Wrapper class useful for hiera based deployments
class mongodb::replset(
  $sets           = undef,
  $admin_username = $mongodb::params::admin_username,
) inherits mongodb::params {

  if $sets {
    create_resources(mongodb_replset, $sets)
  }

  # Order replset before any DB's and shard config
  Mongodb_replset <| |> -> Mongodb::Db <| |>
  Mongodb_replset <| |> -> Mongodb_shard <| |>
  Mongodb_replset <| |> -> Mongodb_user <| |>
}
