require 'spec_helper_acceptance'

describe 'mongodb_database' do
  context 'with default port' do
    it 'compiles with no errors' do
      pp = <<-EOS
        class { 'mongodb::server': }
        -> class { 'mongodb::client': }
        -> mongodb_database { 'testdb': ensure => present }
        ->
        mongodb_user {'testuser':
          ensure        => present,
          password_hash => mongodb_password('testuser', 'passw0rd'),
          database      => 'testdb',
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'creates the user' do
      shell("mongo testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('1')
      end
    end
  end

  context 'with custom port' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mongodb::server': port => 27018 }
        -> class { 'mongodb::client': }
        -> mongodb_database { 'testdb': ensure => present }
        ->
        mongodb_user {'testuser':
          ensure        => present,
          password_hash => mongodb_password('testuser', 'passw0rd'),
          database      => 'testdb',
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'creates the user' do
      shell("mongo testdb --quiet --port 27018 --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('1')
      end
    end
  end

  context 'with the basic roles syntax' do
    it 'compiles with no errors' do
      pp = <<-EOS
        class { 'mongodb::server': }
        -> class { 'mongodb::client': }
        -> mongodb_database { 'testdb': ensure => present }
        ->
        mongodb_user {'testuser':
          ensure        => present,
          password_hash => mongodb_password('testuser', 'passw0rd'),
          database      => 'testdb',
          roles         => ['readWrite', 'dbAdmin'],
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'creates the user' do
      shell("mongo testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('1')
      end
    end
  end

  context 'with the new multidb role syntax' do
    it 'compiles with no errors' do
      pp = <<-EOS
        class { 'mongodb::server': }
        -> class { 'mongodb::client': }
        -> mongodb_database { 'testdb': ensure => present }
        -> mongodb_database { 'testdb2': ensure => present }
        ->
        mongodb_user {'testuser':
          ensure        => present,
          password_hash => mongodb_password('testuser', 'passw0rd'),
          database      => 'testdb',
          roles         => ['readWrite', 'dbAdmin'],
        }
        ->
        mongodb_user {'testuser2':
          ensure        => present,
          password_hash => mongodb_password('testuser2', 'passw0rd'),
          database      => 'testdb2',
          roles         => ['readWrite', 'dbAdmin', 'readWrite@testdb', 'dbAdmin@testdb'],
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'allows the testuser' do
      shell("mongo testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('1')
      end
    end

    it 'assigns roles to testuser' do
      shell("mongo testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\"); db.getUser(\"testuser\")[\"roles\"].forEach(function(role){print(role.role + \"@\" + role.db)})'") do |r|
        expect(r.stdout.split(%r{\n})).to contain_exactly('readWrite@testdb', 'dbAdmin@testdb')
      end
    end

    it 'allows the second user to connect to its default database' do
      shell("mongo testdb2 --quiet --eval 'db.auth(\"testuser2\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('1')
      end
    end

    it 'assigns roles to testuser2' do
      shell("mongo testdb2 --quiet --eval 'db.auth(\"testuser2\",\"passw0rd\"); db.getUser(\"testuser2\")[\"roles\"].forEach(function(role){print(role.role + \"@\" + role.db)})'") do |r|
        expect(r.stdout.split(%r{\n})).to contain_exactly('readWrite@testdb2', 'dbAdmin@testdb2', 'readWrite@testdb', 'dbAdmin@testdb')
      end
    end
  end
end
