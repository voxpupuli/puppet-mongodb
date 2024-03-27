# frozen_string_literal: true

require 'spec_helper_acceptance'

repo_version = ENV.fetch('BEAKER_FACTER_mongodb_repo_version', nil)
repo_ver_param = "repo_version => '#{repo_version}'" if repo_version

describe 'mongodb_user', if: supported_version?(default[:platform], repo_version) do
  context 'with default server port' do
    it 'compiles with no errors' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::server': }
        -> class { 'mongodb::client': }

        mongodb_database { 'testdb': ensure => present }

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
      shell("mongosh testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('{ ok: 1 }')
      end
    end

    it 'removes a user with no errors' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::server': }
        -> class { 'mongodb::client': }

        mongodb_database { 'testdb': ensure => present }

        mongodb_user {'testuser':
          ensure        => absent,
          password_hash => mongodb_password('testuser', 'passw0rd'),
          database      => 'testdb',
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'auth should fail' do
      auth_result = shell("mongosh testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\")'", acceptable_exit_codes: [1])
      expect(auth_result.exit_code).to eq 1
      expect(auth_result.stderr).to match %r{MongoServerError: Authentication failed}
    end
  end

  context 'with custom server port' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::server': port => 27018 }
        -> class { 'mongodb::client': }

        mongodb_database { 'testdb': ensure => present }

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
      shell("mongosh testdb --quiet --port 27018 --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('{ ok: 1 }')
      end
    end
  end

  context 'with the basic roles syntax' do
    it 'compiles with no errors' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::server': }
        -> class { 'mongodb::client': }

        mongodb_database { 'testdb': ensure => present }

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
      shell("mongosh testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('{ ok: 1 }')
      end
    end
  end

  context 'with the new multidb role syntax' do
    it 'compiles with no errors' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::server': }
        -> class { 'mongodb::client': }

        mongodb_database { 'testdb': ensure => present }

        mongodb_database { 'testdb2': ensure => present }

        mongodb_user {'testuser':
          ensure        => present,
          password_hash => mongodb_password('testuser', 'passw0rd'),
          database      => 'testdb',
          roles         => ['readWrite', 'dbAdmin'],
        }

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
      shell("mongosh testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('{ ok: 1 }')
      end
    end

    it 'assigns roles to testuser' do
      shell("mongosh testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\"); db.getUser(\"testuser\")[\"roles\"].forEach(function(role){print(role.role + \"@\" + role.db)})'") do |r|
        expect(r.stdout.split(%r{\n})).to contain_exactly('readWrite@testdb', 'dbAdmin@testdb')
      end
    end

    it 'allows the second user to connect to its default database' do
      shell("mongosh testdb2 --quiet --eval 'db.auth(\"testuser2\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('{ ok: 1 }')
      end
    end

    it 'assigns roles to testuser2' do
      shell("mongosh testdb2 --quiet --eval 'db.auth(\"testuser2\",\"passw0rd\"); db.getUser(\"testuser2\")[\"roles\"].forEach(function(role){print(role.role + \"@\" + role.db)})'") do |r|
        expect(r.stdout.split(%r{\n})).to contain_exactly('readWrite@testdb2', 'dbAdmin@testdb2', 'readWrite@testdb', 'dbAdmin@testdb')
      end
    end
  end
end
