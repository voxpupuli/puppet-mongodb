require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mongodb'))
Puppet::Type.type(:mongodb_user).provide(:mongodb, :parent => Puppet::Provider::Mongodb) do

  desc "Manage users for a MongoDB database."

  defaultfor :kernel => 'Linux'

  def self.instances
    require 'json'
    users = JSON.parse mongo_eval('printjson(db.system.users.find().toArray())')

    users.collect do |user|
        new(:name          => user['_id'],
            :ensure        => :present,
            :username      => user['user'],
            :database      => user['db'],
            :roles         => from_roles(user['roles'], user['db']),
            :password_hash => user['credentials']['MONGODB-CR'])
    end
  end

  # Assign prefetched users based on username and database, not on id and name
  def self.prefetch(resources)
    users = instances
    resources.each do |name, resource|
      if provider = users.find { |user| user.username == resource[:username] and user.database == resource[:database] }
        resources[name].provider = provider
      end
    end
  end

  mk_resource_methods

  def create
    user = {
        :user => @resource[:username],
        :pwd => @resource[:password_hash],
        :customData => { :createdBy => "Puppet Mongodb_user['#{@resource[:name]}']" },
        :roles => @resource[:roles]
    }

    mongo_eval("db.createUser(#{user.to_json})", @resource[:database])

    @property_hash[:ensure] = :present
    @property_hash[:username] = @resource[:username]
    @property_hash[:database] = @resource[:database]
    @property_hash[:password_hash] = ''
    @property_hash[:rolse] = @resource[:roles]

    exists? ? (return true) : (return false)
  end


  def destroy
    mongo_eval("db.dropUser('#{@resource[:username]}')")
  end

  def exists?
    !(@property_hash[:ensure] == :absent or @property_hash[:ensure].nil?)
  end

  def password_hash=(value)
    cmd = {
        :updateUser => @resource[:username],
        :pwd => @resource[:password_hash],
        :digestPassword => false
    }

    mongo_eval("db.runCommand(#{cmd.to_json})", @resource[:database])
  end

  def roles=(roles)
    grant = roles-@resource[:roles]
    if grant.length > 0
      mongo_eval("db.getSiblingDB('#{@resource[:database]}').grantRolesToUser('#{@resource[:username]}', #{grant. to_json})")
    end

    revoke = @resource[:roles]-roles
    if revoke.length > 0
      mongo_eval("db.getSiblingDB('#{@resource[:database]}').revokeRolesFromUser('#{@resource[:username]}', #{revoke.to_json})")
    end
  end

  private

  def self.from_roles(roles, db)
    roles.map do |entry|
        if entry['db'] == db
            entry['role']
        else
            "#{entry['role']}@#{entry['db']}"
        end
    end.sort
  end

end
