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
    mongosh_config = {}
    mongosh_config = YAML.load_file("#{Facter.value(:root_home)}/.mongosh.yaml") if File.file?("#{Facter.value(:root_home)}/.mongosh.yaml")
    # determine if we need the tls for connecion or client
    if mongosh_config['admin'] && mongosh_config['admin']['tlsCertificateKeyFile']
      tlscert = mongosh_config['admin']['tlsCertificateKeyFile']
      auth_mech = mongosh_config['admin']['auth_mechanism'] if mongosh_config['admin']['auth_mechanism']
    else
      tlscert =config['net.tls.certificateKeyFile']
    end

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
      'tlscert' => tlscert,
      'tlsca' => config['net.tls.CAFile'],
      'auth' => config['security.authorization'],
      'auth_mechanism' => auth_mech,
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

      tls_ca = config['tlsca']
      args += ['--tlsCAFile', tls_ca] unless tls_ca.nil?
      args += ['--tlsCertificateKeyFile', config['tlscert']]

      args.push('--tlsAllowInvalidHostnames') if tls_invalid_hostnames(config)
    end

    if config['auth_mechanism'] && config['auth_mechanism'] == 'x509'
      args.push("--authenticationDatabase '$external' --authenticationMechanism MONGODB-X509")
    end

    args += ['--eval', "\"#{cmd}\""]
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

    begin
      res = mongosh_cmd(db, conn_string, cmd_ismaster).to_s.split(%r{\n}).last.chomp
    rescue StandardError => e
      res = mongosh_cmd(db, conn_string, 'db.isMaster().ismaster').to_s.chomp if auth_enabled && e.message =~ %r{Authentication failed}
    end

    res.eql?('true')
  end

  def db_ismaster
    self.class.db_ismaster
  end

  def self.auth_enabled(config = nil)
    config ||= mongo_conf
    config['auth'] && config['auth'] != 'disabled'
  end

  def self.rs_initiated?
    # TODO: not used yet, generates a stack level to deep error
    cmd_status = "rs.status('localhost').set"
    cmd_status = mongoshrc_file + cmd_status if mongoshrc_file
    db = 'admin'
    res = mongosh_cmd(db, conn_string, cmd_status).to_s.split(%r{\n}).last.chomp

    # Retry command without authentication when mongorc_file is set and authentication failed
    res = mongosh_cmd(db, conn_string, "rs.status('localhost').set").to_s.chomp if mongorc_file && res =~ %r{Authentication failed}

    res == @resource[:name]
  end

  # Mongo Command Wrapper
  def self.mongo_eval(cmd, db = 'admin', retries = 10, host = nil)
    retry_count = retries
    retry_sleep = 3
    no_auth_cmd = cmd
    cmd = mongoshrc_file + cmd if mongoshrc_file

    out = nil
    begin
      out = if host
              mongosh_cmd(db, host, cmd)
            else
              mongosh_cmd(db, conn_string, cmd)
            end
    rescue StandardError => e
      # When using the rc file, we get this eror because in most cases the admin user is not created yet
      # Can/must we move this out of the resue block ?
      if auth_enabled && e.message =~ %r{Authentication failed}
        out = if host
                mongosh_cmd(db, host, no_auth_cmd)
              else
                mongosh_cmd(db, conn_string, no_auth_cmd)
              end
      else
        retry_count -= 1
        if retry_count.positive?
          sleep retry_sleep
          retry
        end
      end
    end

    # return also the error message, so caller can react on it
    raise Puppet::ExecutionFailure, "Could not evaluate MongoDB shell command: #{cmd} with #{e.message}" unless out

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
end
