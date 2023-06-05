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
    if File.exist? '/etc/mongod.conf'
      '/etc/mongod.conf'
    else
      '/etc/mongodb.conf'
    end
  end

  def self.mongo_conf
    config = YAML.load_file(mongod_conf_file) || {}
    {
      'bindip' => config['net.bindIp'],
      'port' => config['net.port'],
      'ipv6' => config['net.ipv6'],
      'sslallowInvalidHostnames' => config['net.ssl.allowInvalidHostnames'],
      'ssl' => config['net.ssl.mode'],
      'sslcert' => config['net.ssl.PEMKeyFile'],
      'sslca' => config['net.ssl.CAFile'],
      'tlsallowInvalidHostnames' => config['net.tls.allowInvalidHostnames'],
      'tls' => config['net.tls.mode'],
      'tlscert' => config['net.tls.certificateKeyFile'],
      'tlsca' => config['net.tls.CAFile'],
      'auth' => config['security.authorization'],
      'shardsvr' => config['sharding.clusterRole'],
      'confsvr' => config['sharding.clusterRole']
    }
  end

  def self.ipv6_is_enabled(config = nil)
    config ||= mongo_conf
    config['ipv6']
  end

  def self.ssl_is_enabled(config = nil)
    config ||= mongo_conf
    ssl_mode = config.fetch('ssl')
    !ssl_mode.nil? && ssl_mode != 'disabled'
  end

  def self.tls_is_enabled(config = nil)
    config ||= mongo_conf
    tls_mode = config.fetch('tls')
    !tls_mode.nil? && tls_mode != 'disabled'
  end

  def self.ssl_invalid_hostnames(config = nil)
    config ||= mongo_conf
    config['sslallowInvalidHostnames']
  end

  def self.tls_invalid_hostnames(config = nil)
    config ||= mongo_conf
    config['tlsallowInvalidHostnames']
  end

  def self.mongosh_cmd(db, host, cmd)
    config = mongo_conf

    args = [db, '--quiet', '--host', host]
    args.push('--ipv6') if ipv6_is_enabled(config)

    if ssl_is_enabled(config)
      args.push('--ssl')
      args += ['--sslPEMKeyFile', config['sslcert']]

      ssl_ca = config['sslca']
      args += ['--sslCAFile', ssl_ca] unless ssl_ca.nil?

      args.push('--sslAllowInvalidHostnames') if ssl_invalid_hostnames(config)
    end

    if tls_is_enabled(config)
      args.push('--tls')
      args += ['--tlsCertificateKeyFile', config['tlscert']]

      tls_ca = config['tlsca']
      args += ['--tlsCAFile', tls_ca] unless tls_ca.nil?

      args.push('--tlsAllowInvalidHostnames') if tls_invalid_hostnames(config)
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
                  Facter.value(:fqdn)
                when %r{\[?::0\]?}
                  Facter.value(:fqdn)
                else
                  first_ip_in_list
                end
    end

    port = config.fetch('port')
    shardsvr = config.fetch('shardsvr')
    confsvr = config.fetch('confsvr')
    port_real = if port
                  port
                elsif !port && (confsvr.eql?('configsvr') || confsvr.eql?('true'))
                  27_019
                elsif !port && (shardsvr.eql?('shardsvr') || shardsvr.eql?('true'))
                  27_018
                else
                  27_017
                end

    "#{ip_real}:#{port_real}"
  end

  def self.db_ismaster
    cmd_ismaster = 'db.isMaster().ismaster'
    cmd_ismaster = mongoshrc_file + cmd_ismaster if mongoshrc_file
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
  def self.mongo_eval(cmd, db = 'admin', retries = 10, host = nil)
    retry_count = retries
    retry_sleep = 3
    cmd = mongoshrc_file + cmd if mongoshrc_file

    out = nil
    begin
      out = if host
              mongosh_cmd(db, host, cmd)
            else
              mongosh_cmd(db, conn_string, cmd)
            end
    rescue StandardError => e
      retry_count -= 1
      if retry_count.positive?
        Puppet.debug "Request failed: '#{e.message}' Retry: '#{retries - retry_count}'"
        sleep retry_sleep
        retry
      end
    end

    raise Puppet::ExecutionFailure, "Could not evaluate MongoDB shell command: #{cmd}" unless out

    Puppet::Util::MongodbOutput.sanitize(out)
  end

  def mongo_eval(cmd, db = 'admin', retries = 10, host = nil)
    self.class.mongo_eval(cmd, db, retries, host)
  end

  # Mongo Version checker
  def self.mongo_version
    @mongo_version ||= mongo_eval('db.version()')
  end

  def mongo_version
    self.class.mongo_version
  end

  def self.mongo_4?
    v = mongo_version
    !v[%r{^4\.}].nil?
  end

  def mongo_4?
    self.class.mongo_4?
  end

  def self.mongo_5?
    v = mongo_version
    !v[%r{^5\.}].nil?
  end

  def mongo_5?
    self.class.mongo_5?
  end

  def self.mongo_6?
    v = mongo_version
    !v[%r{^6\.}].nil?
  end

  def mongo_6?
    self.class.mongo_6?
  end
end
