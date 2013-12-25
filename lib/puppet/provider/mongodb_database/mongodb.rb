Puppet::Type.type(:mongodb_database).provide(:mongodb) do

  desc "Manages MongoDB database."

  defaultfor :kernel => 'Linux'

  commands :mongo => 'mongo'

  def create
    mongo(@resource[:name], '--quiet', '--eval', "db.dummyData.insert({\"created_by_puppet\": 1})")
  end

  def destroy
    mongo(@resource[:name], '--quiet', '--eval', 'db.dropDatabase()')
  end

  def exists?
    mongo("--eval", 'db.getMongo().getDBNames()').split(",").include?(@resource[:name])
  end

end
