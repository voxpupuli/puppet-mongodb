require 'spec_helper'
require 'puppet/util/mongodb_output'
require 'json'

describe Puppet::Util::MongodbOutput do
  let(:bson_data) do
    <<-EOT
      {
        "setName": "rs_test",
        "ismaster": true,
        "secondary": false,
        "hosts": [
          "mongo1:27017"
        ],
        "primary": "mongo1:27017",
        "me": "mongo1:27017",
        "maxBsonObjectSize": 16777216,
        "maxMessageSizeBytes": 48000000,
        "hash": BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
        "keyId": NumberLong(0),
        "clusterTime": Timestamp(1538381287, 1),
        "replicaSetId": ObjectId("5bb1d270137a581ebd3d61f2"),
        "slaveDelay": NumberLong(-1),
        "majorityWriteDate": ISODate("2018-10-01T08:08:01Z"),
        "lastHeartbeat": ISODate("2018-10-01T08:08:05.859Z"),
        "ok": 1
      }
    EOT
  end

  let(:json_data) do
    <<-EOT
      {
        "setName": "rs_test",
        "ismaster": true,
        "secondary": false,
        "hosts": [
          "mongo1:27017"
        ],
        "primary": "mongo1:27017",
        "me": "mongo1:27017",
        "maxBsonObjectSize": 16777216,
        "maxMessageSizeBytes": 48000000,
        "hash": 0,
        "keyId": 0,
        "clusterTime": 1538381287,
        "replicaSetId": "5bb1d270137a581ebd3d61f2",
        "slaveDelay": -1,
        "majorityWriteDate": "2018-10-01T08:08:01Z",
        "lastHeartbeat": "2018-10-01T08:08:05.859Z",
        "ok": 1
      }
    EOT
  end

  let(:corrupted_output) do
    <<-EOT
    Error: Authentication failed.
    2021-05-11T15:35:19.647+0200 E QUERY    [thread1] Error: Could not retrieve replica set config: {
    	"ok" : 0,
    	"errmsg" : "not authorized on admin to execute command { replSetGetConfig: 1.0, $clusterTime: { clusterTime: Timestamp(0, 0), signature: { hash: BinData(0, 0000000000000000000000000000000000000000), keyId: 0 } }, $readPreference: { mode: \"secondaryPreferred\" }, $db: \"admin\" }",
    	"code" : 13,
    	"codeName" : "Unauthorized",
    	"$clusterTime" : {
    		"clusterTime" : Timestamp(0, 0),
    		"signature" : {
    			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
    			"keyId" : NumberLong(0)
    		}
    	}
    } :
    rs.conf@src/mongo/shell/utils.js:1323:11
    @(shell eval):1:43'
    EOT
  end

  let(:corrected_corrupted_output) do
    <<-EOT
    {
    	"ok" : 0,
    	"errmsg" : "not authorized on admin to execute command { replSetGetConfig: 1.0, $clusterTime: { clusterTime: 0, signature: { hash: 0, keyId: 0 } }, $readPreference: { mode: \\"secondaryPreferred\\" }, $db: \\"admin\\" }",
    	"code" : 13,
    	"codeName" : "Unauthorized",
    	"$clusterTime" : {
    		"clusterTime" : 0,
    		"signature" : {
    			"hash" : 0,
    			"keyId" : 0
    		}
    	}
    }
    EOT
  end

  describe '.sanitize' do
    it 'returns a valid json' do
      sanitized_json = described_class.sanitize(bson_data)
      expect { JSON.parse(sanitized_json) }.not_to raise_error
    end
    it 'replaces data types' do
      sanitized_json = described_class.sanitize(bson_data)
      expect(JSON.parse(sanitized_json)).to include(JSON.parse(json_data))
    end

    it 'extracts json from a corrupted output' do
      sanitized_json = described_class.sanitize(corrupted_output)
      expect(JSON.parse(sanitized_json)).to eq(JSON.parse(corrected_corrupted_output))
    end

    it 'returns string as is if no json there' do
      expect(described_class.sanitize('3.6.3')).to eq('3.6.3')
    end
  end
end
