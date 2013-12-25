Puppet::Type.type(:mongodb_user).provide(:mongodb) do

  desc "Manage users for a MongoDB database."

  defaultfor :kernel => 'Linux'

  commands :mongo => 'mongo'

  def create
    mongo(@resource[:database], '--eval', "db.system.users.insert({user:\"#{@resource[:name]}\", pwd:\"#{@resource[:password_hash]}\", roles: #{@resource[:roles].inspect}})")
  end

  def destroy
    mongo(@resource[:database], '--quiet', '--eval', "db.removeUser(\"#{@resource[:name]}\")")
  end

  def exists?
    mongo(@resource[:database], '--quiet', '--eval', "db.system.users.find({user:\"#{@resource[:name]}\"}).count()").strip.eql?('1')
  end

  def password_hash
    mongo(@resource[:database], '--quiet', '--eval', "db.system.users.findOne({user:\"#{@resource[:name]}\"})[\"pwd\"]").strip
  end

  def password_hash=(value)
    mongo(@resource[:database], '--quiet', '--eval', "db.system.users.update({user:\"#{@resource[:name]}\"}, { $set: {pwd:\"#{value}\"}})")
  end

  def roles
    mongo(@resource[:database], '--quiet', '--eval', "db.system.users.findOne({user:\"#{@resource[:name]}\"})[\"roles\"]").strip.split(",")
  end

  def roles=(value)
    mongo(@resource[:database], '--quiet', '--eval', "db.system.users.update({user:\"#{@resource[:name]}\"}, { $set: {roles: #{@resource[:roles].inspect}}})")
  end

end
