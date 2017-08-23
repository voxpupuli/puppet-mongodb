require 'json'
require 'yaml'

def get_mongod_conf_file
  if File.exists? '/etc/mongod.conf'
    file = '/etc/mongod.conf'
  else
    file = '/etc/mongodb.conf'
  end
  file
end

Facter.add('mongodb_is_master') do
  setcode do
    if Facter::Core::Execution.which('mongo')
      file = get_mongod_conf_file
      config = YAML.load_file(file)
      mongoPort = nil
      if config.kind_of?(Hash) # Using a valid YAML file for mongo 2.6
        unless config['net.port'].nil?
          mongoPort = "--port #{config['net.port']}"
        end
        if config['net.ssl.mode'] == "requireSSL"
          ssl = "--ssl --host #{Facter.value(:fqdn)}"
        end
        unless config['net.ssl.PEMKeyFile'].nil?
          sslkey = "--sslPEMKeyFile #{config['net.ssl.PEMKeyFile']}"
        end
        unless config['net.ssl.CAFile'].nil?
          sslca = "--sslCAFile #{config['net.ssl.CAFile']}"
        end
        unless config['net.ipv6'].nil?
          ipv6 = "--ipv6"
        end
      else # It has to be a key-value config file
        config = {}
        File.readlines(file).collect do |line|
          k,v = line.split('=')
          config[k.rstrip] = v.lstrip.chomp if k and v
        end
        unless config['port'].nil?
          mongoPort = "--port #{config['port']}"
        end
        if config['ssl'] == "requireSSL"
          ssl = "--ssl --host #{Facter.value(:fqdn)}"
        end
        unless config['sslcert'].nil?
          sslkey = "--sslPEMKeyFile #{config['sslcert']}"
        end
        unless config['sslca'].nil?
          sslca = "--sslCAFile #{config['sslca']}"
        end
        unless config['ipv6'].nil?
          ipv6 = "--ipv6"
        end
      end
      e = File.exists?('/root/.mongorc.js') ? 'load(\'/root/.mongorc.js\'); ' : ''

      # Check if the mongodb server is responding:
      Facter::Core::Execution.exec("mongo --quiet #{ssl} #{sslkey} #{sslca} #{ipv6} #{mongoPort} --eval \"#{e}printjson(db.adminCommand({ ping: 1 }))\"")

      if $?.success?
        Facter::Core::Execution.exec("mongo --quiet #{ssl} #{sslkey} #{sslca} #{ipv6} #{mongoPort} --eval \"#{e}db.isMaster().ismaster\"")
      else
        'not_responding'
      end
    else
      'not_installed'
    end
  end
end
