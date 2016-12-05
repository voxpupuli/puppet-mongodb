Puppet::Type.newtype(:mongodb_user) do
  @doc = 'Manage a MongoDB user. This includes management of users password as well as privileges.'

  ensurable

  def initialize(*args)
    super
    # Sort roles array before comparison.
    self[:roles] = Array(self[:roles]).sort!
  end

  newparam(:name, :namevar=>true) do
    desc "The name of the resource."
  end

  newproperty(:username) do
    desc "The name of the user."
    defaultto { @resource[:name] }
  end

  newproperty(:database) do
    desc "The user's target database."
    defaultto do
      fail("Parameter 'database' must be set") if provider.database == :absent
    end
    newvalues(/^\w+$/)
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
    defaultto do
      fail("Property 'password_hash' must be set. Use mongodb_password() for creating hash.") if provider.database == :absent
    end
    newvalue(/^\w+$/)

    def insync?(is)
      # In older server versions, |is| will just be a password hash, so
      # check that.
      if is == self.should
        return true
      end

      # Otherwise, we have a new-style scram password hash.  Convert our
      # user-supplied parameter to this, then compare them.
      require 'base64'
      require 'digest'
      require 'openssl'

      salt = Base64.decode64 is['salt']
      iters = is['iterationCount']
      salted_pw = OpenSSL::PKCS5::pbkdf2_hmac(self.should, salt, iters, 20, 'SHA1')
      client_key = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), salted_pw, "Client Key")
      stored_key = Digest::SHA1.digest client_key
      server_key = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), salted_pw, "Server Key")

      if Base64.decode64(is['storedKey']) == stored_key and Base64.decode64(is['serverKey']) == server_key
        return true
      else
        return false
      end
    end
  end

  autorequire(:package) do
    'mongodb_client'
  end

  autorequire(:service) do
    'mongodb'
  end
end
