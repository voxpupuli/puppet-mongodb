# @summary This installs Ops Manager
#
# @example To install Ops Manager and have it run with a local MongoDB application server do the following:
#   class {'mongodb::opsmanager':
#     opsmanager_url       => 'http://opsmanager.yourdomain.com'
#     mongo_uri            => 'mongodb://yourmongocluster:27017,
#     from_email_addr      => 'opsmanager@yourdomain.com',
#     reply_to_email_addr  => 'replyto@yourdomain.com',
#     admin_email_addr     => 'admin@yourdomain.com',
#     smtp_server_hostname => 'email-relay.yourdomain.com'
#   }
#
# @param user
#   The user that owns the config file
# @param group
#   The group that owns the config file
#
# @param ensure
#   Used to ensure that the package is installed and the service is running, or that the package is absent/purged
#   and the service is stopped.
#
# @param package_name
#   his setting can be used to specify the name of the package that should be installed.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param package_ensure
#   This setting can be used to specify if puppet should install the package or not.
#
# @param service_enable
#   This setting can be used to specify if the service should be enable at boot.
#
# @param service_manage
#   Whether or not the MongoDB sharding service resource should be part of the catalog.
#
# @param service_name
#   This setting can be used to override the default Mongos service name.
#   If not specified, the module will use whatever service name is the default for your OS distro.
#
# @param download_url
#   This setting can be used to override the default MongoDB Ops-Manager download location.
#
# @param mongo_uri
#   Connection string to the mongod cluster.
#
# @param opsmanager_url
#   The fully qualified url where opsmanager runs. Must include the port.
#
# @param client_certificate_mode
#   Client certificate authorization mode.
#
# @param from_email_addr
#   Email  address ussed as sender
#
# @param reply_to_email_addr
#   Reply to email address to use
#
# @param admin_email_addr
#   Adminsitrator's email address
#
# @param email_dao_class
#   The email delivery agent class to use
#
# @param mail_transport
#   The email transport type to use
#
# @param smtp_server_hostname
#   Hostname of the email server to use.
#
# @param smtp_server_port
#   email port on the email server to use.
#
# @param ssl
#   Set to true to enable ssl.
#
# @param ignore_ui_setup
#   Wheter to install ui or not.
#
# @param ca_file
#   Ca file for secure connection to backup agents.

# @param pem_key_file
#   Pem key file containing the cert and private key used for secure connections to backup agents.

# @param pem_key_password
#   The password to the pem key file.
#
# @param user_svc_class
#   The user svc class
#   Default: com.xgen.svc.mms.svc.user.UserSvcDb
#   External Source: com.xgen.svc.mms.svc.user.UserSvcCrowd
#   Internal Database: com.xgen.svc.mms.svc.user.UserSvcDb
#
# @param snapshot_interval
#   The snapshot interval to use
#
# @param snapshot_interval_retention
#   The snapshot interval retention period
#
# @param snapshot_daily_retention
#   The dayly snapshot interval retention period
#
# @param snapshot_weekly_retention
#   The weekly snapshot interval retention period
#
# @param snapshot_monthly_retention
#   The monthly snapshot interval retention period
#
# @param versions_directory
#   The directory where to store the snapshot versions
#
class mongodb::opsmanager (
  String[1] $user                                = 'mongodb-mms',
  String[1] $group                               = 'mongodb-mms',
  Enum['running', 'stopped'] $ensure             = 'running',
  String[1] $package_name                        = 'mongodb-mms',
  String[1] $package_ensure                      = 'present',
  Boolean $service_enable                        = true,
  Boolean $service_manage                        = true,
  String[1] $service_name                        = 'mongodb-mms',
  Stdlib::Httpurl $download_url                  = 'https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-4.0.1.50101.20180801T1117Z-1.x86_64.rpm',
  String[1] $mongo_uri                           = 'mongodb://127.0.0.1:27017',
  Stdlib::Httpurl $opsmanager_url                = "http://${facts['networking']['fqdn']}:8080",
  String[1] $client_certificate_mode             = 'None',
  String[1] $from_email_addr                     = 'from@example.com',
  String[1] $reply_to_email_addr                 = 'reply-to@example.com',
  String[1] $admin_email_addr                    = 'admin@example.com',
  String[1] $email_dao_class                     = 'com.xgen.svc.core.dao.email.JavaEmailDao', #AWS SES: com.xgen.svc.core.dao.email.AwsEmailDao or SMTP: com.xgen.svc.core.dao.email.JavaEmailDao
  Enum['smtp','smtps'] $mail_transport           = 'smtp',
  Stdlib::Host $smtp_server_hostname             = 'smtp.example.com', # if email_dao_class is SMTP: Email hostname your email provider specifies.
  Stdlib::Port $smtp_server_port                 = 25,
  Boolean $ssl                                   = false,
  Boolean $ignore_ui_setup                       = true,
  #optional settings
  Optional[String[1]] $ca_file                   = undef,
  Optional[String[1]] $pem_key_file              = undef,
  Optional[String[1]] $pem_key_password          = undef,
  Optional[String[1]] $user_svc_class            = undef, # Default: com.xgen.svc.mms.svc.user.UserSvcDb External Source: com.xgen.svc.mms.svc.user.UserSvcCrowd or Internal Database: com.xgen.svc.mms.svc.user.UserSvcDb
  Optional[Integer] $snapshot_interval           = undef, # Default: 24
  Optional[Integer] $snapshot_interval_retention = undef, # Default: 2
  Optional[Integer] $snapshot_daily_retention    = undef, # Default: 0
  Optional[Integer] $snapshot_weekly_retention   = undef, # Default: 2
  Optional[Integer] $snapshot_monthly_retention  = undef, # Default: 1
  Optional[Integer] $versions_directory          = undef, # Linux default: /opt/mongodb/mms/mongodb-releases/
) {
  case $package_ensure {
    'absent': {
      $my_package_ensure = 'absent'
      $file_ensure       = 'absent'
    }
    default:  {
      $my_package_ensure = $package_ensure
      $file_ensure       = 'present'
    }
  }

  $config_file = '/opt/mongodb/mms/conf/conf-mms.properties'

  package { $package_name:
    ensure => $my_package_ensure,
    source => $download_url,
  }

  file { $config_file:
    ensure  => $file_ensure,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => epp('mongodb/opsmanager/conf-mms.properties.epp'),
  }

  if $service_manage {
    service { $service_name:
      ensure => $ensure,
      enable => $service_enable,
    }
  }

  if $mongo_uri == 'mongodb://127.0.0.1:27017' {
    include mongodb::server
  }

  if $ensure == 'running' {
    Package[$package_name] -> File[$config_file]
    if $service_manage {
      [Package[$package_name], File[$config_file]] ~> Service[$service_name]
    }
  }
}
