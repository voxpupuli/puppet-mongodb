# frozen_string_literal: true

require 'spec_helper_acceptance'

if hosts.length > 1
  describe 'mongodb_replset resource' do
    after :all do
      # Have to drop the DB to disable replsets for further testing
      on hosts, %{mongosh local --verbose --eval 'db.dropDatabase()'}

      pp = <<-EOS
        class { 'mongodb::globals': }
        -> class { 'mongodb::server':
          ensure         => absent,
          package_ensure => absent,
          service_ensure => stopped
        }
      EOS

      apply_manifest_on(hosts.reverse, pp, catch_failures: true)
    end

    it 'configures mongo on both nodes' do
      pp = <<-EOS
        class { 'mongodb::globals': }
        -> class { 'mongodb::server':
          bind_ip => '0.0.0.0',
          replset => 'test',
        }
      EOS

      apply_manifest_on(hosts.reverse, pp, catch_failures: true)
      apply_manifest_on(hosts.reverse, pp, catch_changes: true)
    end

    it 'sets up the replset with puppet' do
      pp = <<-EOS
        mongodb_replset { 'test':
          members => [#{hosts.map { |x| "'#{x}:27017'" }.join(',')}],
        }
      EOS
      apply_manifest_on(hosts_as('master'), pp, catch_failures: true)
      on(hosts_as('master'), 'mongosh --quiet --eval "EJSON.stringify(rs.conf())"') do |r|
        expect(r.stdout).to match %r{#{hosts[0]}:27017}
        expect(r.stdout).to match %r{#{hosts[1]}:27017}
      end
    end

    it 'inserts data on the master' do
      sleep(30)
      on hosts_as('master'), %{mongosh --verbose --eval 'db.test.save({name:"test1",value:"some value"})'}
    end

    it 'checks the data on the master' do
      on hosts_as('master'), %{mongosh --verbose --eval 'EJSON.stringify(db.test.findOne({name:"test1"}))'} do |r|
        expect(r.stdout).to match %r{some value}
      end
    end

    it 'checks the data on the slave' do
      sleep(10)
      on hosts_as('slave'), %{mongosh --verbose --eval 'db.getMongo().setReadPref("primaryPreferred"); EJSON.stringify(db.test.findOne({name:"test1"}))'} do |r|
        expect(r.stdout).to match %r{some value}
      end
    end
  end

  describe 'mongodb_replset resource with auth => true' do
    after :all do
      # Have to drop the DB to disable replsets for further testing
      on hosts, %{mongosh local --verbose --eval 'db.dropDatabase()'}

      pp = <<-EOS
        class { 'mongodb::globals': }
        -> class { 'mongodb::server':
          ensure => absent,
          package_ensure => absent,
          service_ensure => stopped
        }
      EOS

      apply_manifest_on(hosts.reverse, pp, catch_failures: true)
    end

    it 'configures mongo on both nodes' do
      pp = <<~EOS
                class { 'mongodb::globals':
                  version             => '2.6.9-1',
                  manage_package_repo => true
                } ->
                class { 'mongodb::server':
                  admin_username => 'admin',
                  admin_password => 'password',
                  auth           => true,
                  bind_ip        => '0.0.0.0',
                  replset        => 'test',
                  keyfile        => '/var/lib/mongodb/mongodb-keyfile',
                  key            => '+dxlTrury7xtD0FRqFf3YWGnKqWAtlyauuemxuYuyz9POPUuX1Uj3chGU8MFMHa7
        UxASqex7NLMALQXHL+Th4T3dyb6kMZD7KiMcJObO4M+JLiX9drcTiifsDEgGMi7G
        vYn3pWSm5TTDrHJw7RNWfMHw3sHk0muGQcO+0dWv3sDJ6SiU8yOKRtYcTEA15GbP
        ReDZuHFy1T1qhk5NIt6pTtPGsZKSm2wAWIOa2f2IXvpeQHhjxP8aDFb3fQaCAqOD
        R7hrimqq0Nickfe8RLA89iPXyadr/YeNBB7w7rySatQBzwIbBUVGNNA5cxCkwyx9
        E5of3xi7GL9xNxhQ8l0JEpofd4H0y0TOfFDIEjc7cOnYlKAHzBgog4OcFSILgUaF
        kHuTMtv0pj+MMkW2HkeXETNII9XE1+JiZgHY08G7yFEJy87ttUoeKmpbI6spFz5U
        4K0amj+N6SOwXaS8uwp6kCqay0ERJLnw+7dKNKZIZdGCrrBxcZ7wmR/wLYrxvHhZ
        QpeXTxgD5ebwCR0cf3Xnb5ql5G/HHKZDq8LTFHwELNh23URGPY7K7uK+IF6jSEhq
        V2H3HnWV9teuuJ5he9BB/pLnyfjft6KUUqE9HbaGlX0f3YBk/0T3S2ESN4jnfRTQ
        ysAKvQ6NasXkzqXktu8X4fS5QNqrFyqKBZSWxttfJBKXnT0TxamCKLRx4AgQglYo
        3KRoyfxXx6G+AjP1frDJxFAFEIgEFqRk/FFuT/y9LpU+3cXYX1Gt6wEatgmnBM3K
        g+Bybk5qHv1b7M8Tv9/I/BRXcpLHeIkMICMY8sVPGmP8xzL1L3i0cws8p5h0zPBa
        YG/QX0BmltAni8owgymFuyJgvr/gaRX4WHbKFD+9nKpqJ3ocuVNuCDsxDqLsJEME
        nc1ohyB0lNt8lHf1U00mtgDSV3fwo5LkwhRi6d+bDBTL/C6MZETMLdyCqDlTdUWG
        YXIsJ0gYcu9XG3mx10LbdPJvxSMg'

                }
      EOS

      apply_manifest_on(hosts.reverse, pp, catch_failures: true)
      apply_manifest_on(hosts.reverse, pp, catch_changes: true)
    end

    it 'sets up the replset with puppet' do
      pp = <<~EOS
                class { 'mongodb::globals':
                  version             => '2.6.9-1',
                  manage_package_repo => true
                } ->
                class { 'mongodb::server':
                  create_admin   => true,
                  admin_username => 'admin',
                  admin_password => 'password',
                  auth           => true,
                  bind_ip        => '0.0.0.0',
                  replset        => 'test',
                  keyfile        => '/var/lib/mongodb/mongodb-keyfile',
                  key            => '+dxlTrury7xtD0FRqFf3YWGnKqWAtlyauuemxuYuyz9POPUuX1Uj3chGU8MFMHa7
        UxASqex7NLMALQXHL+Th4T3dyb6kMZD7KiMcJObO4M+JLiX9drcTiifsDEgGMi7G
        vYn3pWSm5TTDrHJw7RNWfMHw3sHk0muGQcO+0dWv3sDJ6SiU8yOKRtYcTEA15GbP
        ReDZuHFy1T1qhk5NIt6pTtPGsZKSm2wAWIOa2f2IXvpeQHhjxP8aDFb3fQaCAqOD
        R7hrimqq0Nickfe8RLA89iPXyadr/YeNBB7w7rySatQBzwIbBUVGNNA5cxCkwyx9
        E5of3xi7GL9xNxhQ8l0JEpofd4H0y0TOfFDIEjc7cOnYlKAHzBgog4OcFSILgUaF
        kHuTMtv0pj+MMkW2HkeXETNII9XE1+JiZgHY08G7yFEJy87ttUoeKmpbI6spFz5U
        4K0amj+N6SOwXaS8uwp6kCqay0ERJLnw+7dKNKZIZdGCrrBxcZ7wmR/wLYrxvHhZ
        QpeXTxgD5ebwCR0cf3Xnb5ql5G/HHKZDq8LTFHwELNh23URGPY7K7uK+IF6jSEhq
        V2H3HnWV9teuuJ5he9BB/pLnyfjft6KUUqE9HbaGlX0f3YBk/0T3S2ESN4jnfRTQ
        ysAKvQ6NasXkzqXktu8X4fS5QNqrFyqKBZSWxttfJBKXnT0TxamCKLRx4AgQglYo
        3KRoyfxXx6G+AjP1frDJxFAFEIgEFqRk/FFuT/y9LpU+3cXYX1Gt6wEatgmnBM3K
        g+Bybk5qHv1b7M8Tv9/I/BRXcpLHeIkMICMY8sVPGmP8xzL1L3i0cws8p5h0zPBa
        YG/QX0BmltAni8owgymFuyJgvr/gaRX4WHbKFD+9nKpqJ3ocuVNuCDsxDqLsJEME
        nc1ohyB0lNt8lHf1U00mtgDSV3fwo5LkwhRi6d+bDBTL/C6MZETMLdyCqDlTdUWG
        YXIsJ0gYcu9XG3mx10LbdPJvxSMg'
                }
                mongodb_replset { 'test':
                  auth_enabled => true,
                  members      => [#{hosts.map { |x| "'#{x}:27017'" }.join(',')}],
                  before       => Mongodb_user['admin']
                }
      EOS
      apply_manifest_on(hosts_as('master'), pp, catch_failures: true)
      apply_manifest_on(hosts_as('master'), pp, catch_changes: true)
      on(hosts_as('master'), 'mongosh --quiet --eval "load(\'/root/.mongoshrc.js\');EJSON.stringify(rs.conf())"') do |r|
        expect(r.stdout).to match %r{#{hosts[0]}:27017}
        expect(r.stdout).to match %r{#{hosts[1]}:27017}
      end
    end

    it 'inserts data on the master' do
      sleep(30)
      on hosts_as('master'), %{mongosh test --verbose --eval 'load("/root/.mongoshrc.js");db.dummyData.insert({"created_by_puppet": 1})'}
    end

    it 'checks the data on the master' do
      on hosts_as('master'), %{mongosh test --verbose --eval 'load("/root/.mongoshrc.js");EJSON.stringify(db.dummyData.findOne())'} do |r|
        expect(r.stdout).to match %r{created_by_puppet}
      end
    end

    it 'checks the data on the slave' do
      sleep(10)
      on hosts_as('slave'), %{mongosh test --verbose --eval 'load("/root/.mongoshrc.js");db.getMongo().setReadPref("primaryPreferred");EJSON.stringify(db.dummyData.findOne())'} do |r|
        expect(r.stdout).to match %r{created_by_puppet}
      end
    end
  end
end
