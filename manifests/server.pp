# @summary This installs a MongoDB server.
#
# Most of the parameters manipulate the mongod.conf file.
#
#  For more details about configuration parameters consult the MongoDB Configuration File Options.
#
# @example Basic usage.
#   include mongodb::server
#
# @example Overrule settings
#   class {'mongodb::server':
#     port    => 27018,
#     verbose => true,
#  }
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
# @param pidfilemode
#   The file mode of the pidfilepath
#
# @param pidfilepath
#   Specify a file location to hold the PID or process ID of the mongod process.
#   If not specified, the module will use the default for your OS distro.
#
# @param manage_pidfile
#   Should puppet create the pidfile. Mongod 6.2.10 will not start if pidfile exists
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
# @param logpath
#   Specify the path to a file name for the log file that will hold all diagnostic logging information.
#   Unless specified, mongod will output all log information to the standard output.
#
# @param bind_ip
#   Set this option to configure the mongod or mongos process to bind to and listen for connections from
#   applications on this address. If not specified, the module will use the default for your OS distro.
#
# @param ipv6
#   This setting has to be true to configure MongoDB to turn on ipv6 support. If not specified and ipv6
#   address is passed to MongoDB bind_ip it will just fail.
#
# @param logappend
#   Set to true to add new entries to the end of the logfile rather than overwriting the content of the log
#   when the process restarts.
#
# @param system_logrotate
#   Set to reopen for mongo to close a log file then reopen it so that logrotations handled outside of mongo
#   perform as expected.
#
# @param fork
#   Set to true to fork server process at launch time. The default setting depends on the operating system.
#
# @param port
#   Specifies a TCP port for the server instance to listen for client connections.
#
# @param journal
#   Set to true to enable operation journaling to ensure write durability and data consistency.
#
# @param nojournal
#   Set nojournal = true to disable durability journaling. By default, mongod enables journaling in 64-bit versions after v2.0.
#   Note: You must use journal to enable journaling on 32-bit systems.
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
#  et to true to enable database authentication for users connecting from remote hosts. If no users exist,
#  the localhost interface will continue to have access to the database until you create the first user.
#
# @param noauth
#   Disable authentication.
#
# @param verbose
#   Increases the amount of internal reporting returned on standard output or in the log file generated by logpath.
#
# @param verbositylevel
#   MongoDB has the following levels of verbosity: v, vv, vvv, vvvv and vvvvv.
#
# @param objcheck
#   Forces the mongod to validate all requests from clients upon receipt to ensure that clients never insert
#   invalid documents into the database.
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
# @param maxconns
#   Specifies a value to set the maximum number of simultaneous connections that MongoDB will accept.
#   Unless set, MongoDB will not limit its own connections.
#
# @param oplog_size
#    Specifies a maximum size in megabytes for the replication operation log (e.g. oplog.) mongod creates an
#    oplog based on the maximum amount of space available. For 64-bit systems, the oplog is typically 5% of
#    available disk space.
#
# @param nohints
#   Ignore query hints.
#
# @param nohttpinterface
#   Set to true to disable the HTTP interface. This command will override the rest and disable the HTTP
#   interface if you specify both.
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
# @param rest
#   Set to true to enable a simple REST interface.
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
# @param  key
#   Specify the key contained within the keyfile. This option is only useful for the connection between
#   replica set members.
#
# @param set_parameter
#   Specify extra configuration file parameters (i.e. textSearchEnabled=true).
#
# @param  syslog
#   Sends all logging output to the host’s syslog system rather than to standard output or a log file.
#   Important: You cannot use syslog with logpath. Set logpath to false to disable it.
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
# @param ssl
#   Use SSL validation.
#   Important: You need to have ssl_key set as well, and the file needs to pre-exist on node. If you wish to
#   use certificate validation, ssl_ca must also be set.
#
# @param ssl_key
#   Defines the path of the file that contains the TLS/SSL certificate and key.
#
# @param ssl_ca
#   Defines the path of the file that contains the certificate chain for verifying client certificates.
#
# @param ssl_weak_cert
#   Set to true to disable mandatory SSL client authentication.
#
# @param ssl_invalid_hostnames
#   Set to true to disable fqdn SSL cert check.
#
# @param ssl_mode
#   Ssl authorization mode.
#
# @param tls
#   Ensure tls is enabled.
#
# @param tls_key
#   Defines the path of the file that contains the TLS/SSL certificate and key.
#
# @param tls_ca
#   Defines the path of the file that contains the certificate chain for verifying client certificates.
#
# @param tls_conn_without_cert
#   Set to true to bypass client certificate validation for clients that do not present a certificate.
#
# @param tls_invalid_hostnames
#   Set to true to disable the validation of the hostnames in TLS certificates.
#
# @param tls_mode
#   Defines if TLS is used for all network connections. Allowed values are 'requireTLS', 'preferTLS' or 'allowTLS'.
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
# @param  admin_password
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
  Variant[Boolean, String] $ensure                                        = $mongodb::params::ensure,
  String $user                                                            = $mongodb::params::user,
  String $group                                                           = $mongodb::params::group,
  Stdlib::Absolutepath $config                                            = $mongodb::params::config,
  Stdlib::Absolutepath $dbpath                                            = $mongodb::params::dbpath,
  Boolean $dbpath_fix                                                     = $mongodb::params::dbpath_fix,
  Optional[Stdlib::Absolutepath] $pidfilepath                             = $mongodb::params::pidfilepath,
  String $pidfilemode                                                     = $mongodb::params::pidfilemode,
  Boolean $manage_pidfile                                                 = $mongodb::params::manage_pidfile,
  String $rcfile                                                          = $mongodb::params::rcfile,
  Boolean $service_manage                                                 = $mongodb::params::service_manage,
  Optional[String] $service_provider                                      = $mongodb::params::service_provider,
  Optional[String] $service_name                                          = $mongodb::params::service_name,
  Boolean $service_enable                                                 = $mongodb::params::service_enable,
  Enum['stopped', 'running'] $service_ensure                              = $mongodb::params::service_ensure,
  Optional[Enum['stopped', 'running']] $service_status                    = $mongodb::params::service_status,
  Variant[Boolean, String] $package_ensure                                = $mongodb::params::package_ensure,
  String $package_name                                                    = $mongodb::params::server_package_name,
  Variant[Boolean, Stdlib::Absolutepath] $logpath                         = $mongodb::params::logpath,
  Array[Stdlib::IP::Address] $bind_ip                                     = $mongodb::params::bind_ip,
  Optional[Boolean] $ipv6                                                 = undef,
  Boolean $logappend                                                      = true,
  Optional[String] $system_logrotate                                      = undef,
  Optional[Boolean] $fork                                                 = $mongodb::params::fork,
  Optional[Integer[1, 65535]] $port                                       = undef,
  Optional[Boolean] $journal                                              = $mongodb::params::journal,
  Optional[Boolean] $nojournal                                            = undef,
  Optional[Boolean] $smallfiles                                           = undef,
  Optional[Boolean] $cpu                                                  = undef,
  Boolean $auth                                                           = false,
  Optional[Boolean] $noauth                                               = undef,
  Optional[Boolean] $verbose                                              = undef,
  Optional[String] $verbositylevel                                        = undef,
  Optional[Boolean] $objcheck                                             = undef,
  Optional[Boolean] $quota                                                = undef,
  Optional[Integer] $quotafiles                                           = undef,
  Optional[Integer[0, 7]] $diaglog                                        = undef,
  Optional[Boolean] $directoryperdb                                       = undef,
  $profile                                                                = undef,
  Optional[Integer] $maxconns                                             = undef,
  Optional[Integer] $oplog_size                                           = undef,
  $nohints                                                                = undef,
  Optional[Boolean] $nohttpinterface                                      = undef,
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
  Optional[Boolean] $rest                                                 = undef,
  Optional[Boolean] $quiet                                                = undef,
  Optional[Integer] $slowms                                               = undef,
  Optional[Stdlib::Absolutepath] $keyfile                                 = undef,
  Optional[Variant[String[6], Sensitive[String[6]]]] $key                 = undef,
  Optional[Variant[String[1], Array[String[1]]]] $set_parameter           = undef,
  Optional[Boolean] $syslog                                               = undef,
  $config_content                                                         = undef,
  Optional[String] $config_template                                       = undef,
  Optional[Hash] $config_data                                             = undef,
  Optional[Boolean] $ssl                                                  = undef,
  Optional[Stdlib::Absolutepath] $ssl_key                                 = undef,
  Optional[Stdlib::Absolutepath] $ssl_ca                                  = undef,
  Boolean $ssl_weak_cert                                                  = false,
  Boolean $ssl_invalid_hostnames                                          = false,
  Enum['requireSSL', 'preferSSL', 'allowSSL'] $ssl_mode                   = 'requireSSL',
  Boolean $tls                                                            = false,
  Optional[Stdlib::Absolutepath] $tls_key                                 = undef,
  Optional[Stdlib::Absolutepath] $tls_ca                                  = undef,
  Boolean $tls_conn_without_cert                                          = false,
  Boolean $tls_invalid_hostnames                                          = false,
  Enum['requireTLS', 'preferTLS', 'allowTLS'] $tls_mode                   = 'requireTLS',
  Boolean $restart                                                        = $mongodb::params::restart,
  Optional[String] $storage_engine                                        = undef,
  Boolean $create_admin                                                   = $mongodb::params::create_admin,
  String $admin_username                                                  = $mongodb::params::admin_username,
  Optional[Variant[String, Sensitive[String]]] $admin_password            = undef,
  Optional[Variant[String[1], Sensitive[String[1]]]] $admin_password_hash = undef,
  Enum['scram_sha_1', 'scram_sha_256'] $admin_auth_mechanism              = $mongodb::params::admin_auth_mechanism,
  Boolean $admin_update_password                                          = false,
  Boolean $handle_creds                                                   = $mongodb::params::handle_creds,
  Boolean $store_creds                                                    = $mongodb::params::store_creds,
  Array $admin_roles                                                      = $mongodb::params::admin_roles,
) inherits mongodb::params {
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
