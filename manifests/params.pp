# Class: datadog_agent::params
#
# This class contains the parameters for the Datadog module
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog_agent::params {
  $datadog_site                   = 'datadoghq.com'
  $agent5_enable                  = false
  $conf_dir                       = '/etc/dd-agent/conf.d'
  $conf6_dir                      = '/etc/datadog-agent/conf.d'
  $dd_user                        = 'dd-agent'
  $dd_group                       = 'root'
  $dd_groups                      = undef
  $package_name                   = 'datadog-agent'
  $service_name                   = 'datadog-agent'
  $agent_version                  = 'latest'
  $dogapi_version                 = 'installed'
  $gem_provider                   = 'puppetserver_gem'
  $conf_dir_purge                 = false
  $apt_default_release            = 'stable'
  $apm_default_enabled            = false
  $process_default_enabled        = false
  $process_default_scrub_args     = true
  $process_default_custom_words   = []
  $logs_enabled                   = false
  $container_collect_all          = false
  $use_apt_backup_keyserver       = false
  $apt_backup_keyserver           = 'hkp://pool.sks-keyservers.net:80'
  $apt_keyserver                  = 'hkp://keyserver.ubuntu.com:80'

  case $::operatingsystem {
    'Ubuntu','Debian' : {
      $rubydev_package   =  'ruby-dev'
      $agent5_default_repo = 'https://apt.datadoghq.com'
      $agent6_default_repo = 'https://apt.datadoghq.com'
    }
    'RedHat','CentOS','Fedora','Amazon','Scientific' : {
      $rubydev_package   = 'ruby-devel'
      $agent5_default_repo = "https://yum.datadoghq.com/rpm/${::architecture}/"
      $agent6_default_repo = "https://yum.datadoghq.com/stable/6/${::architecture}/"
    }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

}
