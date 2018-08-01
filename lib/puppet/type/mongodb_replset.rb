#
# Author: Francois Charlier <francois.charlier@enovance.com>
#

Puppet::Type.newtype(:mongodb_replset) do
  @doc = 'Manage a MongoDB replicaSet'

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.create
    end
  end

  newparam(:name) do
    desc 'The name of the replicaSet'
  end

  newparam(:arbiter) do
    desc 'The replicaSet arbiter'
  end

  newparam(:initialize_host) do
    desc 'Host to use for Replicaset initialization'
    defaultto '127.0.0.1'
  end

  newproperty(:settings) do
    desc 'The replicaSet settings config'

    def insync?(is)
      should.each do |k,v|
        if v != is[k]
          Puppet.debug "The replicaset settings config is not insync"
          return false
        end
      end
      Puppet.debug "The replicaset settings config is insync"
      return true
    end
  end

  newproperty(:members, array_matching: :all) do
    desc 'The replicaSet members'

    def insync?(is)
      is.sort == should.sort
    end
  end

  autorequire(:package) do
    'mongodb_client'
  end

  autorequire(:service) do
    'mongodb'
  end
end
