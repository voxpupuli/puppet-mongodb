node 'mongos' {
  class { 'mongodb::globals':
    manage_package_repo => true,
  }
  -> class { 'mongodb::server':
    configsvr => true,
    bind_ip   => [$facts['networking']['ip']],
  }
  -> class { 'mongodb::client': }
  -> class { 'mongodb::mongos':
    configdb => ["${facts['networking']['ip']}:27019"],
  }
  -> mongodb_shard { 'rs1' :
    member => 'rs1/mongod1:27018',
    keys   => [{
        'rs1.foo' => {
          'name' => 1,
        }
    }],
  }
}

node 'mongod1' {
  class { 'mongodb::globals':
    manage_package_repo => true,
  }
  -> class { 'mongodb::server':
    shardsvr => true,
    replset  => 'rs1',
    bind_ip  => [$facts['networking']['ip']],
  }
  -> class { 'mongodb::client': }
  mongodb_replset { 'rs1':
    members => ['mongod1:27018', 'mongod2:27018'],
  }
}

node 'mongod2' {
  class { 'mongodb::globals':
    manage_package_repo => true,
  }
  -> class { 'mongodb::server':
    shardsvr => true,
    replset  => 'rs1',
    bind_ip  => [$facts['networking']['ip']],
  }
  -> class { 'mongodb::client': }
  mongodb_replset { 'rs1':
    members => ['mongod1:27018', 'mongod2:27018'],
  }
}
