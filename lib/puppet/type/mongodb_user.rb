Puppet::Type.newtype(:mongodb_user) do
  @doc = 'Manage a MongoDB user. This includes management of users password as well as privileges.'

  ensurable

  def initialize(*args)

    # required to create the password hash from plaintext
    require 'digest/md5'

    super
    # Sort roles array before comparison.
    self[:roles] = Array(self[:roles]).sort!
    if self[:ensure]
      # password_has/password_plain check at initialization:
      if self[:password_hash].nil?
        if self[:password_plain].nil?
          # if neither exist, fail
          fail("Either 'password_hash' or 'password_plain' must be set. For mongodb > 2.4, hash is recommended. Use mongodb_password() for creating hash.")
        else
          # if only plaintext password exists, create the hash from the plain
          self[:password_hash] = Digest::MD5.hexdigest(self[:username] + ":mongo:" + self[:password_plain])
        end
      else
        unless self[:password_plain].nil?
          # if both exist, both they don't correspond to each other, fail
          if self[:password_hash] != Digest::MD5.hexdigest(self[:username] + ":mongo:" + self[:password_plain])
            fail("if both 'password_hash' and 'password_plain' are specified, they must correspond.")
          end
        end
      end
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The name of the resource."
  end

  newproperty(:username) do
    desc "The name of the user."
    defaultto { @resource[:name] }
  end

  #represents a plaintext password (for mongodb <= 2.4)
  #only a parameter, since there's no way to compare it with the current value
  newparam(:password_plain) do
    desc 'The password of the user in plaintext.'
  end

  newproperty(:database) do
    desc "The user's target database."
    defaultto do
      fail("Parameter 'database' must be set") if provider.database == :absent
    end
    newvalues(/^[\w-]+$/)
  end

  newparam(:tries) do
    desc "The maximum amount of two second tries to wait MongoDB startup."
    defaultto 10
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:roles, :array_matching => :all) do
    desc "The user's roles."
    defaultto ['dbAdmin']
    newvalue(/^\w+$/)

    # Pretty output for arrays.
    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end
  end

  newproperty(:password_hash) do
    desc "The password hash of the user. Use mongodb_password() for creating hash."
    newvalue(/^\w+$/)
  end

  autorequire(:package) do
    'mongodb_client'
  end

  autorequire(:service) do
    'mongodb'
  end
end
