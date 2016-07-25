# Class: datadog_agent::params
#
# This class contains the parameters for the Datadog module
#
# Parameters:
#   $api_key:
#       Your DataDog API Key. Please replace with your key value
#   $dd_url
#       The URL to the DataDog application.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog_agent::params {
  $conf_dir       = '/etc/dd-agent/conf.d'
  $dd_user        = 'dd-agent'
  $dd_group       = 'root'
  $package_name   = 'datadog-agent'
  $service_name   = 'datadog-agent'
  $dogapi_version = 'installed'

  case $::operatingsystem {
    'Ubuntu','Debian' : {
      $rubydev_package   =  'ruby-dev'
    }
    'RedHat','CentOS','Fedora','Amazon','Scientific' : {
      $rubydev_package   = 'ruby-devel'
    }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

}
