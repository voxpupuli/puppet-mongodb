# @summary Wrapper class useful for hiera based deployments
#
# @example hieradata
#   mongodb::shardsvr::shards:
#     shard01:
#       keys:
#         - {x: 1}
#       members:
#         - shardhost01.exmaple.com:30000
#         - shardhost02.exmaple.com:30000
#         - shardhost03.exmaple.com:30000
#
# @param shards
#    Hash of attributes as described in the mongodb_shardsvr custom type
#
class mongodb::shardsvr (
  $shards = undef
) {
  if $shards {
    create_resources(mongodb_shard, $shards)
  }
}
