require 'json'

Facter.add('mongodb_is_master') do
  setcode do
    if Facter::Core::Execution.which('mongo')
      e = File.exists?('/root/.mongorc.js') ? 'load(\'/root/.mongorc.js\'); ' : ''

      # Check if the mongodb server is responding:
      Facter::Core::Execution.exec("mongo --quiet --eval \"#{e}printjson(db.adminCommand({ ping: 1 }))\"")

      if $?.success?
        mongo_output = Facter::Core::Execution.exec("mongo --quiet --eval \"#{e}printjson(db.isMaster())\"")
        JSON.parse(mongo_output.gsub(/ISODate\((.+?)\)/, '\1 '))['ismaster'] ||= false
      else
        'not_responding'
      end
    else
      'not_installed'
    end
  end
end
