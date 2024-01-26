# @summary Wrapper class useful for hiera based deployments
#
# @param shards
#
class mongodb::shardsvr (
  $shards = undef
) {
  if $shards {
    create_resources(mongodb_shard, $shards)
  }
}
