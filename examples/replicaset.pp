node default {
  class { 'mongodb::globals':
    manage_package_repo => true,
  }
  -> class { 'mongodb::server':
    net        => {
      bind_ip => [$facts['networking']['ip']],
    },
    smallfiles => true,
    replset    => 'rsmain',
  }
  mongodb_replset { 'rsmain':
    members => ['mongo1:27017', 'mongo2:27017', 'mongo3:27017'],
    arbiter => 'mongo3:27017',
  }
}
