require 'json';

Facter.add('mongodb_is_master') do
  setcode do
    if Facter::Core::Execution.which('mongo')
      mongo_output = Facter::Core::Execution.exec('mongo --quiet --eval "printjson(db.isMaster())" 2>/dev/null')

      if mongo_output =~ /Failed to connect to/
        'failed_to_connect'
      else
        ['ObjectId','ISODate'].each do |data_type|
          mongo_output.gsub!(/#{data_type}\(([^)]*)\)/, '\1')
        end
        JSON.parse(mongo_output)['ismaster'] ||= false
      end
    else
      'not_installed'
    end
  end
end

