# @summary This installs a MongoDB server.
#
# Most of the parameters manipulate the mongod.conf file.
#
#  For more details about configuration parameters consult the MongoDB Configuration File Options.
#
# @param ensure
#   Used to ensure that the package is installed and the service is running, or that the package is
#   absent/purged and the service is stopped.
#
# @param user
#   This setting can be used to override the default MongoDB user and owner of the service and related files in the file system.
#   If not specified, the module will use the default for your OS distro.
#
# @param group
#   This setting can be used to override the default MongoDB user group to be used for related files in the file system.
#   If not specified, the module will use the default for your OS distro.
#
# @param system_log_config
#   Content to add to the systemLog key of the server configuration file
#   If not specified, the module will use the default for your OS distro.
#
# @param process_management_config
#   Content to add to the processManagement key of the server configuration file
#   If not specified, the module will use the default for your OS distro.
#
# @param net_config
#   Content to add to the net key of the server configuration file
#   If not specified, the module will use the default for your OS distro.
#
# @param config
#   Path of the config file. If not specified, the module will use the default for your OS distro.
#
# @param dbpath
#   Set this value to designate a directory for the mongod instance to store it's data.
#   If not specified, the module will use the default for your OS distro.
#
# @param dbpath_fix
#   Set this value to true if you want puppet to recursively manage the permissions of the files in the dbpath
#   directory. If you are using the default dbpath, this should probably be false. Set this to true if you are
#   using a custom dbpath.
#
# @param rcfile
#   The path to the custom mongosh rc file.
#
# @param  service_manage
#   Whether or not the MongoDB service resource should be part of the catalog.
#
# @param service_manage
#   Whether or not the MongoDB sharding service resource should be part of the catalog.
#
# @param service_name
#   This setting can be used to override the default Mongos service name.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param service_provider
#   This setting can be used to override the default Mongos service provider.
#   If not specified, the module will use whatever service provider is the default for your OS distro.
#
# @param service_status
#   This setting can be used to override the default status check command for your Mongos service.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param service_enable
#   This setting can be used to specify if the service should be enable at boot.
#
# @param service_ensure
# This setting can be used to specify if the service should be running.
#
# @param package_ensure
#   This setting can be used to specify if puppet should install the package or not.
#
# @param package_name
#   This setting can be used to specify the name of the package that should be installed.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param journal
#   Enable or disable the durability journal to ensure data files remain valid and recoverable.
#   Available in MongoDB < 7.0
#   Default: true on 64-bit systems, false on 32-bit systems
#
# @param smallfiles
#   Set to true to modify MongoDB to use a smaller default data file size. Specifically, smallfiles reduces
#   the initial size for data files and limits them to 512 megabytes.
#
# @param cpu
#  Set to true to force mongod to report every four seconds CPU utilization and the amount of time that the
#  processor waits for I/O operations to complete (i.e. I/O wait.)
#
# @param auth
#  Set to true to enable database authentication for users connecting from remote hosts. If no users exist,
#  the localhost interface will continue to have access to the database until you create the first user.
#
# @param quota
#   Set to true to enable a maximum limit for the number of data files each database can have. The default
#   quota is 8 data files, when quota is true.
#
# @param quotafiles
#   Modify limit on the number of data files per database. This option requires the quota setting.
#
# @param diaglog
#   Creates a very verbose diagnostic log for troubleshooting and recording various errors. For more
#   information please refer to MongoDB Configuration File Options.
#
# @param directoryperdb
#   Set to true to modify the storage pattern of the data directory to store each database’s files in a distinct folder.
#
# @param profile
#   Modify this value to changes the level of database profiling, which inserts information about operation
#   performance into output of mongod or the log file if specified by logpath.
#
# @param oplog_size
#    Specifies a maximum size in megabytes for the replication operation log (e.g. oplog.) mongod creates an
#    oplog based on the maximum amount of space available. For 64-bit systems, the oplog is typically 5% of
#    available disk space.
#
# @param nohints
#   Ignore query hints.
#
# @param noscripting
#   Set noscripting = true to disable the scripting engine.
#
# @param notablescan
#   Set notablescan = true to forbid operations that require a table scan.
#
# @param noprealloc
#   Set noprealloc = true to disable the preallocation of data files. This will shorten the start up time in
#   some cases, but can cause significant performance penalties during normal operations.
#
# @param nssize
#   Use this setting to control the default size for all newly created namespace files (i.e .ns).
#
# @param mms_token
#   MMS token for mms monitoring.
#
# @param mms_name
#   MMS identifier for mms monitoring.
#
# @param mms_interval
#   MMS interval for mms monitoring.
#
# @param replset
#   Use this setting to configure replication with replica sets. Specify a replica set name as an argument to
#   this set. All hosts must have the same set name.
#
# @param replset_config
#   A hash that is used to configure the replica set. Mutually exclusive with replset_members param.
#   class mongodb::server {
#     replset        => 'rsmain',
#     replset_config => { 'rsmain' => {
#                          ensure => present,
#                          settings => { heartbeatTimeoutSecs => 15, getLastErrorModes => { ttmode => { dc => 1 } } },
#                          members => [{'host' => 'host1:27017', 'tags':{ 'dc' : 'east'}}, { 'host' => 'host2:27017'}, 'host3:27017'] }},
#   }
#
# @param replset_members
#    An array of member hosts for the replica set. Mutually exclusive with replset_config param.
#
# @param configsvr
#   Use this setting to enable config server mode for mongod.
#
# @param shardsvr
#   Use this setting to enable shard server mode for mongod.
#
# @param quiet
#   Runs the mongod or mongos instance in a quiet mode that attempts to limit the amount of output.
#   This option suppresses : "output from database commands, including drop, dropIndexes, diagLogging,
#   validate, and clean", "replication activity", "connection accepted events" and "connection closed events".
#
#   For production systems this option is not recommended as it may make tracking problems during particular
#   connections much more difficult.
#
# @param slowms
#   Sets the threshold for mongod to consider a query “slow” for the database profiler.
#
# @param keyfile
#    Specify the path to a key file to store authentication information. This option is only useful for the
#    connection between replica set members.
#
# @param key
#   Specify the key contained within the keyfile. This option is only useful for the connection between
#   replica set members.
#
# @param set_parameter
#   Specify extra configuration file parameters (i.e. textSearchEnabled=true).
#
# @param config_content
#   Config content if the default doesn't match one needs.
#
# @param config_template
#   Path to the config template if the default doesn't match one needs.
#
# @param config_data
#   A hash to allow for additional configuration options to be set in user-provided template.
#
# @param admin_password_hash
#   Hashed password. Hex encoded md5 hash of mongodb password.
#
# @param restart
#   Specifies whether the service should be restarted on config changes.
#
# @param storage_engine
#   Only needed for MongoDB 3.x versions, where it's possible to select the 'wiredTiger' engine in addition to
#   the default 'mmapv1' engine. If not set, the config is left out and mongo will default to 'mmapv1'.
#
# @param create_admin
#   Allows to create admin user for admin database.
#
# @param admin_username
#   Administrator user name
#
# @param admin_password
#   Administrator user password
#
# @param admin_auth_mechanism
#   Administrator authentication mechanism. scram_sha_256 password synchronization verification is not supported.
#
# @param admin_update_password
#   Update password. Used with SCRAM-SHA-256 because password verification is not supported.
#
# @param admin_roles
#   Administrator user roles
#
# @param handle_creds
#   Set this to false to avoid having puppet handle .mongoshrc.js in case you wish to deliver it by other
#   means. This is needed for facts and providers to work if you have auth set to true.
#
# @param store_creds
#   Store admin credentials in mongoshrc.js file. Uses with create_admin parameter
#
class mongodb::server (
  String[1] $user,
  String[1] $group,
  Stdlib::Absolutepath $dbpath,
  Hash $system_log_config,
  Hash $process_management_config,
  Hash $net_config,
  String[1] $ensure                                                       = 'present',
  Stdlib::Absolutepath $config                                            = '/etc/mongod.conf',
  Boolean $dbpath_fix                                                     = false,
  String $rcfile                                                          = "${facts['root_home']}/.mongoshrc.js",
  Boolean $service_manage                                                 = true,
  Optional[String[1]] $service_provider                                   = undef,
  String[1] $service_name                                                 = 'mongod',
  Boolean $service_enable                                                 = true,
  Enum['stopped', 'running'] $service_ensure                              = 'running',
  Optional[Enum['stopped', 'running']] $service_status                    = undef,
  String[1] $package_ensure                                               = pick($mongodb::globals::version, 'present'),
  String[1] $package_name                                                 = "mongodb-${mongodb::globals::edition}-server",
  Optional[Boolean] $journal                                              = undef,
  Optional[Boolean] $smallfiles                                           = undef,
  Optional[Boolean] $cpu                                                  = undef,
  Boolean $auth                                                           = false,
  Optional[Boolean] $quota                                                = undef,
  Optional[Integer] $quotafiles                                           = undef,
  Optional[Integer[0, 7]] $diaglog                                        = undef,
  Optional[Boolean] $directoryperdb                                       = undef,
  $profile                                                                = undef,
  Optional[Integer] $oplog_size                                           = undef,
  $nohints                                                                = undef,
  Optional[Boolean] $noscripting                                          = undef,
  Optional[Boolean] $notablescan                                          = undef,
  Optional[Boolean] $noprealloc                                           = undef,
  Optional[Integer] $nssize                                               = undef,
  $mms_token                                                              = undef,
  $mms_name                                                               = undef,
  $mms_interval                                                           = undef,
  Optional[String] $replset                                               = undef,
  Optional[Hash] $replset_config                                          = undef,
  Optional[Array] $replset_members                                        = undef,
  Optional[Boolean] $configsvr                                            = undef,
  Optional[Boolean] $shardsvr                                             = undef,
  Optional[Boolean] $quiet                                                = undef,
  Optional[Integer] $slowms                                               = undef,
  Optional[Stdlib::Absolutepath] $keyfile                                 = undef,
  Optional[Variant[String[6], Sensitive[String[6]]]] $key                 = undef,
  Optional[Variant[String[1], Array[String[1]]]] $set_parameter           = undef,
  $config_content                                                         = undef,
  Optional[String] $config_template                                       = undef,
  Optional[Hash] $config_data                                             = undef,
  Boolean $restart                                                        = true,
  Optional[String] $storage_engine                                        = undef,
  Boolean $create_admin                                                   = false,
  String $admin_username                                                  = 'admin',
  Optional[Variant[String, Sensitive[String]]] $admin_password            = undef,
  Optional[Variant[String[1], Sensitive[String[1]]]] $admin_password_hash = undef,
  Enum['scram_sha_1', 'scram_sha_256'] $admin_auth_mechanism              = 'scram_sha_1',
  Boolean $admin_update_password                                          = false,
  Boolean $handle_creds                                                   = true,
  Boolean $store_creds                                                    = false,
  Array[String[1]] $admin_roles                                           = [
    'userAdmin', 'readWrite', 'dbAdmin', 'dbAdminAnyDatabase', 'readAnyDatabase',
    'readWriteAnyDatabase', 'userAdminAnyDatabase', 'clusterAdmin',
    'clusterManager', 'clusterMonitor', 'hostManager', 'root', 'restore',
  ],
) inherits mongodb::globals {
  if $journal != undef {
    if $mongodb::globals::repo_location == undef {
      $_repo_loc_version_match = undef
    } else {
      $_repo_loc_version_match = $mongodb::globals::repo_location.match(/[0-9]+\.[0-9]+/)
    }
    if (
      $mongodb::globals::manage_package_repo
      and $mongodb::globals::repo_location == undef
      and versioncmp($mongodb::globals::repo_version, '7.0') >= 0
    ) or (
      $mongodb::globals::manage_package_repo
      and $mongodb::globals::repo_location != undef
      and $_repo_loc_version_match != undef
      and versioncmp($_repo_loc_version_match[0], '7.0') >= 0
    ) or (
      $package_ensure =~ /\./ and versioncmp($package_ensure, '7.0.0') >= 0
    ) {
      fail('`journal` parameter is only supported for MongoDB < 7.0')
    }
  }

  contain mongodb::server::install
  contain mongodb::server::config
  contain mongodb::server::service

  if ($ensure == 'present' or $ensure == true) {
    Class['mongodb::server::install'] -> Class['mongodb::server::config']

    if $restart {
      # If $restart is true, notify the service on config changes (~>)
      Class['mongodb::server::config'] ~> Class['mongodb::server::service']
    } else {
      # If $restart is false, config changes won't restart the service (->)
      Class['mongodb::server::config'] -> Class['mongodb::server::service']
    }
  } else {
    Class['mongodb::server::service'] -> Class['mongodb::server::config'] -> Class['mongodb::server::install']
  }

  $admin_password_unsensitive = if $admin_password =~ Sensitive[String] {
    $admin_password.unwrap
  } else {
    $admin_password
  }
  if $create_admin and ($service_ensure == 'running' or $service_ensure == true) {
    mongodb::db { 'admin':
      user            => $admin_username,
      auth_mechanism  => $admin_auth_mechanism,
      password        => $admin_password_unsensitive,
      password_hash   => $admin_password_hash,
      roles           => $admin_roles,
      update_password => $admin_update_password,
    }

    # Make sure it runs before other DB creation
    Mongodb::Db['admin'] -> Mongodb::Db <| title != 'admin' |>
  }

  # Set-up replicasets
  if $replset {
    # Check that we've got either a members array or a replset_config hash
    if $replset_members and $replset_config {
      fail('You can provide either replset_members or replset_config, not both.')
    } elsif !$replset_members and !$replset_config {
      # No members or config provided. Warn about it.
      warning('Replset specified, but no replset_members or replset_config provided.')
    } else {
      if $replset_config {
        # Copy it to REAL value
        $_replset_config = $replset_config
      } else {
        # Build up a config hash
        $_replset_config = {
          "${replset}" => {
            'ensure'   => 'present',
            'members'  => $replset_members,
          },
        }
      }

      # Wrap the replset class
      class { 'mongodb::replset':
        sets => $_replset_config,
      }

      $replset_config_real = $_replset_config  # lint:ignore:variable_is_lowercase required for compatibility

      # Make sure that the ordering is correct
      if $create_admin {
        Class['mongodb::replset'] -> Mongodb::Db['admin']
      }
    }
  }
}
