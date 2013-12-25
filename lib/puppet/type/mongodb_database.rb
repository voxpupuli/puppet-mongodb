Puppet::Type.newtype(:mongodb_database) do
  @doc = "Manage MongoDB databases."

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the database."
    newvalues(/^\w+$/)
  end

end
