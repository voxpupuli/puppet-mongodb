# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))
require 'puppet/util/mongodb_output'

require 'yaml'
require 'json'
class Puppet::Provider::Mongodb < Puppet::Provider
  # Without initvars commands won't work.
  initvars
  commands mongosh: 'mongosh'

  # Optional defaults file
  def self.mongoshrc_file
    "load('#{Facter.value(:root_home)}/.mongoshrc.js'); " if File.file?("#{Facter.value(:root_home)}/.mongoshrc.js")
  end

  def mongoshrc_file
    self.class.mongoshrc_file
  end

  def self.mongod_conf_file
    '/etc/mongod.conf'
  end

  def self.mongo_conf
    config = YAML.load_file(mongod_conf_file) || {}
    {
      'bindip' => config['net.bindIp'] || config.fetch('net', {}).fetch('bindIp', nil),
      'port' => config['net.port'] || config.fetch('net', {}).fetch('port', nil),
      'ipv6' => config['net.ipv6'] || config.fetch('net', {}).fetch('ipv6', nil),
      'tlsallowInvalidHostnames' => config['net.tls.allowInvalidHostnames'] || config.fetch('net', {}).fetch('tls', {}).fetch('allowInvalidHostnames', nil),
      'tls' => config['net.tls.mode'] || config.fetch('net', {}).fetch('tls', {}).fetch('mode', nil),
      'tlscert' => config['net.tls.certificateKeyFile'] || config.fetch('net', {}).fetch('tls', {}).fetch('certificateKeyFile', nil),
      'tlsca' => config['net.tls.CAFile'] || config.fetch('net', {}).fetch('tls', {}).fetch('CAFile', nil),
      'auth' => config['security.authorization'] || config.fetch('security', {}).fetch('authorization', nil),
      'clusterRole' => config['sharding.clusterRole'] || config.fetch('sharding', {}).fetch('clusterRole', nil),
    }
  end

  def self.ipv6_is_enabled(config = nil)
    config ||= mongo_conf
    config['ipv6']
  end

  def self.tls_is_enabled(config = nil)
    config ||= mongo_conf
    tls_mode = config.fetch('tls')
    !tls_mode.nil? && tls_mode != 'disabled'
  end

  def self.tls_invalid_hostnames(config = nil)
    config ||= mongo_conf
    config['tlsallowInvalidHostnames']
  end

  def self.tls_invalid_certificates(config = nil)
    config ||= mongo_conf
    config['tlsallowInvalidCertificates']
  end

  def self.mongosh_cmd(db, host, cmd)
    config = mongo_conf

    host = conn_string if host.nil? || host.split(':')[0] == Facter.value(:fqdn) || host == '127.0.0.1'

    args = [db, '--quiet', '--host', host]
    args.push('--ipv6') if ipv6_is_enabled(config)

    if tls_is_enabled(config)
      args.push('--tls')
      args += ['--tlsCertificateKeyFile', config['tlscert']]

      tls_ca = config['tlsca']
      args += ['--tlsCAFile', tls_ca] unless tls_ca.nil?

      args.push('--tlsAllowInvalidHostnames') if tls_invalid_hostnames(config)
      args.push('--tlsAllowInvalidCertificates') if tls_invalid_certificates(config)
    end

    args += ['--eval', cmd]
    mongosh(args)
  end

  def self.conn_string
    config = mongo_conf
    bindip = config.fetch('bindip')
    if bindip
      first_ip_in_list = bindip.split(',').first
      ip_real = case first_ip_in_list
                when '0.0.0.0'
                  '127.0.0.1'
                when %r{\[?::0\]?}
                  '::1'
                else
                  first_ip_in_list
                end
    end

    port = config.fetch('port')
    cluster_role = config.fetch('clusterRole')
    port_real = if port
                  port
                elsif cluster_role.eql?('configsvr')
                  27_019
                elsif cluster_role.eql?('shardsvr')
                  27_018
                else
                  27_017
                end

    "#{ip_real}:#{port_real}"
  end

  def conn_string
    self.class.conn_string
  end

  def self.db_ismaster
    cmd_ismaster = 'db.isMaster().ismaster'
    db = 'admin'
    res = mongosh_cmd(db, conn_string, cmd_ismaster).to_s.split(%r{\n}).last.chomp
    res.eql?('true')
  end

  def db_ismaster
    self.class.db_ismaster
  end

  def self.auth_enabled(config = nil)
    config ||= mongo_conf
    config['auth'] && config['auth'] != 'disabled'
  end

  # Mongo Command Wrapper
  def self.mongo_eval(cmd, db = 'admin', host = nil)
    cmd = mongoshrc_file + cmd if mongoshrc_file

    out = nil
    begin
      out = mongosh_cmd(db, host, cmd)
    rescue StandardError => e
      raise Puppet::ExecutionFailure, "Could not evaluate MongoDB shell command: #{cmd}, with: #{e.message}"
    end

    Puppet::Util::MongodbOutput.sanitize(out)
  end

  def mongo_eval(cmd, db = 'admin', host = nil)
    self.class.mongo_eval(cmd, db, host)
  end

  # Mongo Version checker
  def self.mongo_version
    @mongo_version ||= mongo_eval('db.version()')
  end

  def mongo_version
    self.class.mongo_version
  end
end
