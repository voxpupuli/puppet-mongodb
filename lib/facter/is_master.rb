require 'json'
require 'yaml'

def mongod_conf_file
  locations = ['/etc/mongod.conf', '/etc/mongodb.conf']
  locations.find { |location| File.exist? location }
end

def get_options_from_hash_config(config)
  result = []

  # use --ssl and --host if:
  # - sslMode is "requireSSL"
  # - Parameter --sslPEMKeyFile is set
  # - Parameter --sslCAFile is set
  result << "--port #{config['net.port']}" unless config['net.port'].nil?
  result << "--ssl --host #{Facter.value(:fqdn)}" if ['allowSSL', 'preferSSL', 'requireSSL'].include? config['net.ssl.mode']
  result << "--sslAllowInvalidHostnames" if config['net.ssl.allowInvalidHostnames'] == true
  result << "--sslPEMKeyFile #{config['net.ssl.PEMKeyFile']}" unless config['net.ssl.PEMKeyFile'].nil?
  result << "--sslCAFile #{config['net.ssl.CAFile']}" unless config['net.ssl.CAFile'].nil?
  result << '--ipv6' unless config['net.ipv6'].nil?

  result.join(' ')
end

def get_options_from_keyvalue_config(file)
  config = {}
  File.readlines(file).map do |line|
    k, v = line.split('=')
    config[k.rstrip] = v.lstrip.chomp if k && v
  end

  result = []

  # use --ssl and --host if:
  # - sslMode is "requireSSL"
  # - Parameter --sslPEMKeyFile is set
  # - Parameter --sslCAFile is set
  result << "--port #{config['port']}" unless config['port'].nil?
  result << "--ssl --host #{Facter.value(:fqdn)}" if ['allowSSL', 'preferSSL', 'requireSSL'].include? config['ssl']
  result << "--sslAllowInvalidHostnames" if config['net.ssl.allowInvalidHostnames'] == true
  result << "--sslPEMKeyFile #{config['sslcert']}" unless config['sslcert'].nil?
  result << "--sslCAFile #{config['sslca']}" unless config['sslca'].nil?
  result << '--ipv6' unless config['ipv6'].nil?

  result.join(' ')
end

def get_options_from_config(file)
  config = YAML.load_file(file)
  if config.is_a?(Hash) # Using a valid YAML file for mongo 2.6
    get_options_from_hash_config(config)
  else # It has to be a key-value config file
    get_options_from_keyvalue_config(file)
  end
end

Facter.add('mongodb_is_master') do
  setcode do
    if %w[mongo mongod].all? { |m| Facter::Util::Resolution.which m }
      file = mongod_conf_file
      if file
        options = get_options_from_config(file)
        e = File.exist?('/root/.mongorc.js') ? 'load(\'/root/.mongorc.js\'); ' : ''

        # Check if the mongodb server is responding:
        Facter::Core::Execution.exec("mongo --quiet #{options} --eval \"#{e}printjson(db.adminCommand({ ping: 1 }))\"")

        if $CHILD_STATUS.success?
          Facter::Core::Execution.exec("mongo --quiet #{options} --eval \"#{e}db.isMaster().ismaster\"")
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
