Puppet::Type.newtype(:mongodb_user) do
  @doc = 'Manage a MongoDB user. This includes management of users password as well as privileges.'

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the user."
  end

  newparam(:database) do
    desc "The user's target database."
    defaultto do
      fail("Parameter 'database' must be set")
    end
    newvalues(/^\w+$/)
  end

  newproperty(:roles, :array_matching => :all) do
    desc "The user's roles."
    defaultto ['dbAdmin']
    newvalue(/^\w+$/)
  end

  newproperty(:password_hash) do
    desc "The password hash of the user. Use mongodb_password() for creating hash."
    defaultto do
      fail("Property 'password_hash' must be set. Use mongodb_password() for creating hash.")
    end
    newvalue(/^\w+$/)
  end

end
