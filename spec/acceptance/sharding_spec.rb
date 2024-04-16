# frozen_string_literal: true

require 'spec_helper_acceptance'

repo_version = ENV.fetch('BEAKER_FACTER_mongodb_repo_version', nil)
repo_ver_param = "repo_version => '#{repo_version}'" if repo_version

if hosts.length > 1 && supported_version?(default[:platform], repo_version)
  describe 'mongodb_shard resource' do
    after :all do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::mongos' :
          package_ensure => purged,
          service_ensure => stopped
        }
        -> class { 'mongodb::server':
          ensure         => absent,
          package_ensure => purged,
          service_ensure => stopped
        }
        -> class { 'mongodb::client':
          ensure => purged
        }
      EOS

      apply_manifest_on(hosts.reverse, pp, catch_failures: true)
    end

    it 'configures the shard server' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::client': }
        -> class { 'mongodb::server':
          bind_ip   => ['0.0.0.0'],
          replset   => 'foo',
          shardsvr  => true,
        }
        -> mongodb_replset { 'foo' :
          members => [#{hosts_as('shard').map { |x| "'#{x}:27018'" }.join(',')}],
        }
      EOS

      apply_manifest_on(hosts_as('shard'), pp, catch_failures: true)
      apply_manifest_on(hosts_as('shard'), pp, catch_changes: true)
    end

    it 'configures the router server' do
      pp = <<-EOS
        class { 'mongodb::globals':
          #{repo_ver_param}
        }
        -> class { 'mongodb::client': }
        -> class { 'mongodb::server':
          bind_ip   => ['0.0.0.0'],
          replset   => 'conf',
          configsvr => true,
        }
        -> mongodb_replset { 'conf' :
          members => [#{hosts_as('router').map { |x| "'#{x}:27019'" }.join(',')}],
        }
        -> class { 'mongodb::mongos' :
          configdb => ["conf/#{hosts_as('router').map { |x| "#{x}:27019" }.join(',')}"],
        }
        -> exec { '/bin/sleep 20' :
        }
        -> mongodb_shard { 'foo':
          member => "foo/#{hosts_as('shard').map { |x| "#{x}:27018" }.join(',')}",
          keys   => [{'foo.toto' => {'name' => 1}}]
        }
      EOS

      apply_manifest_on(hosts_as('router'), pp, catch_failures: true, trace: true)
      on(hosts_as('router'), 'mongosh --quiet --eval "EJSON.stringify(sh.status())"') do |r|
        expect(r.stdout).to match %r{foo/#{hosts[0]}:27018}
        expect(r.stdout).to match %r{foo\.toto}
      end
    end
  end
end
