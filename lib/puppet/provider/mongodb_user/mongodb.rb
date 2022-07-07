require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mongodb'))
Puppet::Type.type(:mongodb_user).provide(:mongodb, parent: Puppet::Provider::Mongodb) do
  desc 'Manage users for a MongoDB database.'

  defaultfor kernel: 'Linux'

  def self.instances
    require 'json'

    if db_ismaster
      script = 'printjson(db.system.users.find().toArray())'
      # A hack to prevent prefetching failures until admin user is created
      script = "try {#{script}} catch (e) { if (e.message.match(/not authorized on admin/)) { 'not authorized on admin' } else {throw e}}" if auth_enabled

      out = mongo_eval(script)

      return [] if auth_enabled && out.include?('not authorized on admin')

      users = JSON.parse out

      users.map do |user|
        new(name: user['_id'],
            ensure: :present,
            username: user['user'],
            database: user['db'],
            roles: from_roles(user['roles'], user['db']),
            password_hash: user['credentials']['MONGODB-CR'],
            scram_credentials: user['credentials']['SCRAM-SHA-1'])
      end
    else
      Puppet.warning 'User info is available only from master host'
      return []
    end
  end

  # Assign prefetched users based on username and database, not on id and name
  def self.prefetch(resources)
    users = instances
    resources.each do |name, resource|
      provider = users.find { |user| user.username == resource[:username] && user.database == resource[:database] }
      resources[name].provider = provider if provider
    end
  end

  mk_resource_methods

  def create
    if db_ismaster
      password_hash = @resource[:password_hash]
      if !password_hash && @resource[:password]
        password_hash = Puppet::Util::MongodbMd5er.md5(@resource[:username], @resource[:password])
      end

      command = {
        createUser: @resource[:username],
        customData: {
          createdBy: "Puppet Mongodb_user['#{@resource[:name]}']"
        },
        roles: role_hashes(@resource[:roles], @resource[:database]),
      }

      if mongo_4? || mongo_5?
        if @resource[:auth_mechanism] == :scram_sha_256
          command[:mechanisms] = ['SCRAM-SHA-256']
          command[:pwd] = @resource[:password]
          command[:digestPassword] = true
        else
          command[:mechanisms] = ['SCRAM-SHA-1']
          command[:pwd] = password_hash
          command[:digestPassword] = false
        end
      else
        command[:pwd] = password_hash
        command[:digestPassword] = false
      end

      mongo_eval("db.runCommand(#{command.to_json})", @resource[:database])
    else
      Puppet.warning 'User creation is available only from master host'

      @property_hash[:ensure] = :present
      @property_hash[:username] = @resource[:username]
      @property_hash[:database] = @resource[:database]
      @property_hash[:password_hash] = ''
      @property_hash[:roles] = @resource[:roles]

      exists?
    end
  end

  def destroy
    mongo_eval("db.dropUser(#{@resource[:username].to_json})", @resource[:database])
  end

  def exists?
    !(@property_hash[:ensure] == :absent || @property_hash[:ensure].nil?)
  end

  def password_hash=(_value)
    if db_ismaster
      command = {
        updateUser: @resource[:username],
        pwd: @resource[:password_hash],
        digestPassword: false
      }

      mongo_eval("db.runCommand(#{command.to_json})", @resource[:database])
    else
      Puppet.warning 'User password operations are available only from master host'
    end
  end

  def password=(value)
    if mongo_26?
      mongo_eval("db.changeUserPassword(#{@resource[:username].to_json}, #{value.to_json})", @resource[:database])
    else
      command = {
        updateUser: @resource[:username],
        pwd: @resource[:password],
        digestPassword: true
      }

      if mongo_4? || mongo_5?
        command[:mechanisms] = @resource[:auth_mechanism] == :scram_sha_256 ? ['SCRAM-SHA-256'] : ['SCRAM-SHA-1']
      end

      mongo_eval("db.runCommand(#{command.to_json})", @resource[:database])
    end
  end

  def roles=(roles)
    if db_ismaster
      grant = to_roles(roles, @resource[:database]) - to_roles(@property_hash[:roles], @resource[:database])
      unless grant.empty?
        mongo_eval("db.getSiblingDB(#{@resource[:database].to_json}).grantRolesToUser(#{@resource[:username].to_json}, #{role_hashes(grant, @resource[:database]).to_json})")
      end

      revoke = to_roles(@property_hash[:roles], @resource[:database]) - to_roles(roles, @resource[:database])
      unless revoke.empty?
        mongo_eval("db.getSiblingDB(#{@resource[:database].to_json}).revokeRolesFromUser(#{@resource[:username].to_json}, #{role_hashes(revoke, @resource[:database]).to_json})")
      end
    else
      Puppet.warning 'User roles operations are available only from master host'
    end
  end

  private

  def self.from_roles(roles, db)
    roles.map do |entry|
      if entry['db'].empty? || entry['db'] == db
        entry['role']
      else
        "#{entry['role']}@#{entry['db']}"
      end
    end.sort
  end

  def to_roles(roles, db)
    roles.map do |entry|
      if entry.include? '@'
        entry
      else
        "#{entry}@#{db}"
      end
    end
  end

  def role_hashes(roles, db)
    roles.sort.map do |entry|
      if entry.include? '@'
        {
          'role' => entry.gsub(%r{^(.*)@.*$}, '\1'),
          'db'   => entry.gsub(%r{^.*@(.*)$}, '\1')
        }
      else
        {
          'role' => entry,
          'db'   => db
        }
      end
    end
  end
end
