# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mongodb_database' do
  describe 'creating a database' do
    context 'with default port' do
      it 'compiles with no errors' do
        pp = <<-EOS
          class { 'mongodb::server': }
          -> mongodb::db { 'testdb1':
            user     => 'testuser',
            password => 'testpass',
          }
          -> mongodb::db { 'testdb2':
            user     => 'testuser',
            password => 'testpass',
          }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'creates the databases' do
        shell("mongosh testdb1 --eval 'EJSON.stringify(db.getMongo().getDBs())'")
        shell("mongosh testdb2 --eval 'EJSON.stringify(db.getMongo().getDBs())'")
      end
    end

    context 'with custom port' do
      it 'works with no errors' do
        pp = <<-EOS
          class { 'mongodb::server':
            port => 27018,
          }
          -> mongodb::db { 'testdb1':
            user     => 'testuser',
            password => 'testpass',
          }
          -> mongodb::db { 'testdb2':
            user     => 'testuser',
            password => 'testpass',
          }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'creates the database' do
        shell("mongosh testdb1 --port 27018 --eval 'EJSON.stringify(db.getMongo().getDBs())'")
        shell("mongosh testdb2 --port 27018 --eval 'EJSON.stringify(db.getMongo().getDBs())'")
      end
    end
  end
end
