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
      else # It has to be a key-value config file
        config = {}
        File.readlines(file).collect do |line|
          k,v = line.split('=')
          config[k.rstrip] = v.lstrip.chomp if k and v
        end
        unless config['port'].nil?
          mongoPort = "--port #{config['port']}"
        end
      end
      e = File.exists?('/root/.mongorc.js') ? 'load(\'/root/.mongorc.js\'); ' : ''

      # Check if the mongodb server is responding:
      Facter::Core::Execution.exec("mongo --quiet #{mongoPort} --eval \"#{e}printjson(db.adminCommand({ ping: 1 }))\"")

      if $?.success?
        mongo_output = Facter::Core::Execution.exec("mongo --quiet #{mongoPort} --eval \"#{e}printjson(db.isMaster())\"")
        JSON.parse(mongo_output.gsub(/\w+\(.+?\)/, '"foo"'))['ismaster'] ||= false
      else
        'not_responding'
      end
    else
      'not_installed'
    end
  end
end
