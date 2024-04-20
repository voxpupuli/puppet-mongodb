# frozen_string_literal: true

require 'json'
require 'yaml'

def mongod_conf_file
  '/etc/mongod.conf'
end

def get_options_from_hash_config(config)
  result = []

  port = config['net.port'] || config.fetch('net', {}).fetch('port', nil)
  ipv6 = config['net.ipv6'] || config.fetch('net', {}).fetch('ipv6', nil)
  tls_mode = config['net.tls.mode'] || config.fetch('net', {}).fetch('tls', {}).fetch('mode', nil)
  tls_cert_key = config['net.tls.certificateKeyFile'] || config.fetch('net', {}).fetch('tls', {}).fetch('certificateKeyFile', nil)
  tls_ca = config['net.tls.CAFile'] || config.fetch('net', {}).fetch('tls', {}).fetch('CAFile', nil)

  result << "--port #{port}" unless port.nil?
  result << '--ipv6' if ipv6
  unless tls_mode.nil? || tls_mode == 'disabled'
    result << "--tls --host #{Facter.value(:fqdn)}"
    result << "--tlsCertificateKeyFile #{tls_cert_key}" unless tls_cert_key.nil?
    result << "--tlsCAFile #{tls_ca}" unless tls_ca.nil?
  end

  result.join(' ')
end

def get_options_from_config(file)
  config = YAML.load_file(file)
  get_options_from_hash_config(config)
end

Facter.add('mongodb_is_master') do
  setcode do
    if %w[mongosh mongod].all? { |m| Facter::Util::Resolution.which m }
      file = mongod_conf_file
      if file
        options = get_options_from_config(file)

        # Check if the mongodb server is responding:
        Facter::Core::Execution.exec("mongosh --quiet #{options} --eval \"EJSON.stringify(db.adminCommand({ ping: 1 }))\"")

        if $CHILD_STATUS.success?
          Facter::Core::Execution.exec("mongosh --quiet #{options} --eval \"db.isMaster().ismaster\"")
        else
          'not_responding'
        end
      else
        'not_configured'
      end
    else
      'not_installed'
    end
  end
end
