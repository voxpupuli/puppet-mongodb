require 'json';

Facter.add('mongodb_is_master') do
  setcode do
    if Facter::Core::Execution.which('mongo') 
      mongo_output = Facter::Core::Execution.exec('mongo --quiet --eval "load(\'/root/.mongorc.js\'); printjson(db.isMaster())"')
      JSON.parse(mongo_output.gsub(/ISODate\((.+?)\)/, '\1 '))['ismaster'] ||= false
    else 
      'not_installed'
    end
  end
end
