# frozen_string_literal: true

#
# Author: Francois Charlier <francois.charlier@enovance.com>
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mongodb'))
Puppet::Type.type(:mongodb_replset).provide(:mongo, parent: Puppet::Provider::Mongodb) do
  desc 'Manage hosts members for a replicaset.'

  confine true: begin
    require 'json'
    true
  rescue LoadError
    false
  end

  mk_resource_methods

  def initialize(resource = {})
    super(resource)
    @property_flush = {}
  end

  def settings=(settings)
    @property_flush[:settings] = settings
  end

  def members=(hosts)
    @property_flush[:members] = hosts
  end

  def self.instances
    instance = replset_properties
    if instance
      # There can only be one replset per node
      [new(instance)]
    else
      []
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      resource = resources[prov.name]
      resource.provider = prov if resource
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
    @property_flush[:members] = resource.should(:members)
    @property_flush[:settings] = resource.should(:settings)
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    set_members
    @property_hash = self.class.replset_properties
  end

  private

  def db_ismaster(host)
    mongo_command('db.isMaster()', host)
  end

  def rs_initiate(conf, master)
    if auth_enabled && auth_enabled != 'disabled'
      mongo_command("rs.initiate(#{conf})", initialize_host)
    else
      mongo_command("rs.initiate(#{conf})", master)
    end
  end

  def rs_status(host)
    mongo_command('rs.status()', host)
  end

  def rs_config(host)
    mongo_command('rs.config()', host)
  end

  def rs_add(host_conf, master)
    mongo_command("rs.add(#{host_conf.to_json})", master)
  end

  def rs_remove(host_conf, master)
    host = host_conf['host']
    mongo_command("rs.remove('#{host}')", master)
  end

  def rs_reconfig_member(host_conf, master)
    mongo_command("rsReconfigMember(#{host_conf.to_json})", master)
  end

  def rs_reconfig_settings(settings, master)
    mongo_command("rsReconfigSettings(#{settings.to_json})", master)
  end

  def rs_arbiter
    @resource[:arbiter]
  end

  def rs_add_arbiter(host, master)
    mongo_command("rs.addArb('#{host}')", master)
  end

  def auth_enabled
    self.class.auth_enabled
  end

  def initialize_host
    @resource[:initialize_host]
  end

  def master_host(members)
    members.each do |member|
      status = db_ismaster(member['host'])
      return status['primary'] if status.key?('primary')
    end
    false
  end

  def self.replset_properties
    conn_string = conn_string
    conn_string = conn_string # rubocop:disable Lint/SelfAssignment
    begin
      output = mongo_command('rs.conf()', conn_string)
    rescue Puppet::ExecutionFailure => e
      #if e.message =~ %r{command replSetGetConfig requires authentication} || e.message =~ %r{not authorized on admin to execute command} || e.message =~ %r{no replset config has been received}
      if e.message =~ %r{command replSetGetConfig requires authentication} || e.message =~ %r{not authorized on admin to execute command}
        Puppet.debug('XXXXXXXXX in replset_properties rescue part')
        output = mongo_command('rs.status()', conn_string)
        if output['members']
          memb = []
          output['members'].each do |m|
            memb << { 'host' => m['name'] }
          end
          {
            name: output['set'],
            ensure: :present,
            members: memb,
            #settings: @resource[:settings],
            provider: :mongo
          }
        end
      else
        nil
      end
    end
    if output['members']
      return {
        name: output['_id'], # replica set name
        ensure: :present,
        members: output['members'],
        settings: output['settings'],
        provider: :mongo
      }
    end
    nil
  end

  def get_hosts_status(members)
    alive = []
    members.select do |member|
      host = member['host']
      Puppet.debug "Checking replicaset member #{host} ..."
      begin
        status = rs_status(host)
        Puppet.debug('XXXXXXXXXXXXXX should not get here since I dont have a replicaset')
        raise Puppet::Error, "Can't configure replicaset #{name}, host #{host} is not supposed to be part of a replicaset." if status.key?('errmsg') && status['errmsg'] == 'not running with --replSet'

        if status.key?('set')
          raise Puppet::Error, "Can't configure replicaset #{name}, host #{host} is already part of another replicaset." if status['set'] != name

          # This node is alive and supposed to be a member of our set
          Puppet.debug "Host #{host} is available for replset #{status['set']}"
          alive.push(member)
        elsif status.key?('info')
          Puppet.debug "Host #{host} is alive but unconfigured: #{status['info']}"
          alive.push(member)
        end
      rescue Puppet::ExecutionFailure => e
        Puppet.debug('XXXXXXXXXXXX in rescue checking connection mebers')
        if auth_enabled
          case e.message
          when %r{no replset config has been received}
            Puppet.warning('No replicaset config received, needs initialisation')
          when /Authentication failed/, /not authorized on admin/, /Authentication failed/
            Puppet.warning "Host #{host} is available, but you are unauthorized because of authentication is enabled: #{auth_enabled}"
          when /command replSetGetStatus requires authentication/
            Puppet.warning("Node #{host} is reachable but requires authentication: ReplicaSet not initialized")
          end
          alive.push(member)
        else
          Puppet.warning "Can't connect to replicaset member #{host} (Errormsg: #{e.message})."
        end
      end
    end
    alive.uniq!
    dead = members - alive
    [alive, dead]
  end

  def get_members_changes(current_members_conf, new_members_conf)
    # no changes in members config
    return [[], [], []] if new_members_conf.nil?

    add_members = []
    remove_members = current_members_conf || []
    update_members = []

    new_members_conf.each do |nm|
      next unless remove_members.each_with_index do |om, index|
        next unless nm['host'] == om['host']

        nm.each do |k, v|
          next unless v != om[k]

          # new config for existing node
          update_members.push(nm)
          break
        end
        # node is found, no need to remove it from cluster
        remove_members.delete_at(index)
        break
      end

      # new node for cluster
      add_members.push(nm)
    end

    [add_members.uniq, remove_members.uniq, update_members.uniq]
  end

  def get_replset_settings_changes(current_settings, new_settings)
    new_settings.each do |k, v|
      current_settings[k] = v
    end
    current_settings
  end

  def set_members
    if @property_flush[:ensure] == :absent
      # TODO: I don't know how to remove a node from a replset; unimplemented
      # Puppet.debug "Removing all members from replset #{self.name}"
      # @property_hash[:members].collect do |member|
      #  rs_remove(member, master_host(@property_hash[:members]))
      # end
      return
    end

    Puppet.debug 'Checking for dead and alive members'
    if !@property_flush[:members].nil? && !@property_flush[:members].empty?
      # Find the alive members so we don't try to add dead members to the replset using new config
      alive_hosts, dead_hosts = get_hosts_status(@property_flush[:members])
      Puppet.debug "Alive members: #{alive_hosts.inspect}"
      Puppet.debug "Dead members: #{dead_hosts.inspect}" unless dead_hosts.empty?
      raise Puppet::Error, "Can't connect to any member of replicaset #{name}." if alive_hosts.empty?
    elsif !resource[:members].nil? && !resource[:members].empty?
      # Find the alive members using current 'is' config
      alive_hosts, dead_hosts = get_hosts_status(@resource[:members])
      Puppet.debug "Alive members: #{alive_hosts.inspect}"
      Puppet.debug "Dead members: #{dead_hosts.inspect}" unless dead_hosts.empty?
      raise Puppet::Error, "Can't connect to any member of replicaset #{name}." if alive_hosts.empty?
    else
      alive_hosts = []
    end

    Puppet.debug 'Checking for new replset'
    if @property_flush[:ensure] == :present && @property_hash[:ensure] != :present && !master_host(alive_hosts)
      Puppet.debug "Initializing the replset #{name}"

      # Create a replset configuration
      members_conf = alive_hosts.each_with_index.map do |host, id|
        member = host
        member['_id'] = id
        member
      end

      replset_conf = {
        _id: name,
        members: members_conf,
        settings: (@property_flush[:settings].nil? ? {} : @property_flush[:settings])
      }.to_json

      Puppet.debug "Starting replset config is #{replset_conf.to_json}"
      # Set replset members with the first host as the master
      output = rs_initiate(replset_conf, alive_hosts[0]['host'])
      raise Puppet::Error, "rs.initiate() failed for replicaset #{name}: #{output['errmsg']}" if output['ok'].zero?

      # Check that the replicaset has finished initialization
      retry_limit = 10
      retry_sleep = 3

      retry_limit.times do |n|
        if db_ismaster(alive_hosts[0]['host'])['ismaster']
          Puppet.debug 'Replica set initialization has successfully ended'
          return true
        else
          Puppet.debug "Wainting for replica initialization. Retry: #{n}"
          sleep retry_sleep
          next
        end
      end
      raise Puppet::Error, "rs.initiate() failed for replicaset #{name}: host #{alive_hosts[0]['host']} didn't become master"

    else
      Puppet.debug "Checking for replset #{name} changes"
      master = master_host(alive_hosts)
      raise Puppet::Error, "Can't find master host for replicaset #{name}." unless master

      master_rs_config = rs_config(master)
      add_members, remove_members, update_members = get_members_changes(master_rs_config['members'], @property_flush[:members])

      Puppet.debug "Members to be Added: #{add_members.inspect}" unless add_members.empty?
      add_members.each do |member|
        retry_limit = 10
        retry_sleep = 3

        output = {}
        retry_limit.times do |n|
          output = rs_add(member, master)
          if output['ok'].zero?
            Puppet.debug "Retry adding host to replicaset. Retry: #{n}"
            sleep retry_sleep
            master = master_host(alive_hosts)
          else
            Puppet.debug 'Host successfully added to replicaset'
            break
          end
        end
        raise Puppet::Error, "rs.add() failed to add host to replicaset #{name}: #{output['errmsg']}" if output['ok'].zero?
      end

      Puppet.debug "Members to be Removed: #{remove_members.inspect}" unless remove_members.empty?
      remove_members.each do |member|
        retry_limit = 10
        retry_sleep = 3

        output = {}
        retry_limit.times do |n|
          output = rs_remove(member, master)
          if output['ok'].zero?
            Puppet.debug "Retry removing host from replicaset. Retry: #{n}"
            sleep retry_sleep
            master = master_host(alive_hosts)
          else
            Puppet.debug 'Host successfully removed from replicaset'
            break
          end
        end
        raise Puppet::Error, "rs.remove() failed to remove host from replicaset #{name}: #{output['errmsg']}" if output['ok'].zero?
      end

      Puppet.debug "Members to be Updated: #{update_members.inspect}" unless update_members.empty?
      update_members.each do |member|
        retry_limit = 10
        retry_sleep = 3

        output = {}
        retry_limit.times do |n|
          output = rs_reconfig_member(member, master)
          if output['ok'].zero?
            Puppet.debug "Retry updating host in replicaset. Retry: #{n}"
            sleep retry_sleep
            master = master_host(alive_hosts)
          else
            Puppet.debug 'Host successfully updated in replicaset'
            break
          end
        end
        raise Puppet::Error, "rs.reconfig() failed to update host in replicaset #{name}: #{output['errmsg']}" if output['ok'].zero?
      end

      if !@property_flush[:settings].nil? && !@property_flush[:settings].empty?
        settings = get_replset_settings_changes(master_rs_config, @property_flush[:settings])
        Puppet.warning "Updating settings for replset #{name}"
        retry_limit = 10
        retry_sleep = 3
        output = {}
        retry_limit.times do |n|
          output = rs_reconfig_settings(settings, master)
          if output['ok'].zero?
            Puppet.debug "Retry updating settings in replicaset. Retry: #{n}"
            sleep retry_sleep
            master = master_host(alive_hosts)
          else
            Puppet.debug 'Settings successfully updated in replicaset'
            break
          end
        end
        raise Puppet::Error, "rs.reconfig() failed to update settings in replicaset #{name}: #{output['errmsg']}" if output['ok'].zero?
      end
    end
  end

  def mongo_command(command, host, retries = 4)
    self.class.mongo_command(command, host, retries)
  end

  def self.mongo_command(command, host = nil, retries = 4)
    #begin
      output = mongo_eval("EJSON.stringify(#{command})", 'admin', retries, host)
    #rescue Puppet::ExecutionFailure => e
      #if e.message =~ %r{no replset config has been received} || e.message =~ %r{Authentication failed}
      if output =~ %r{no replset config has been received} || output =~ %r{Authentication failed}
        output = '{}'
     # else
     #   Puppet.debug "Got an exception: #{e}"
     #   raise
      end
    #end

    # Hack to avoid non-json empty sets
    output = '{}' if output == "null\n"
    output = '{}' if output == "\nnull\n"

    # Parse the JSON output and return
    JSON.parse(output)
  end
end
