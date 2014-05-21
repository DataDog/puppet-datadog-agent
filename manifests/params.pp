# Class: datadog::params
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
class datadog::params {
  $api_key      = "your API key"
  $dd_url       = "https://app.datadoghq.com"
  $conf_dir     = "/etc/dd-agent/conf.d"
  $dd_user      = "dd-agent"
  $dd_group     = "root"
  $service_name = "datadog-agent"
  $mongodb_servers = []

  case $operatingsystem {
    "Ubuntu","Debian" : {
      $rubygems_package  = 'rubygems'
      $rubydev_package   =  'ruby-dev'
      $mysql_int_package = 'python-mysqldb'
      $mongodb_int_package = 'python-pymongo'
    }
    "RedHat","CentOS","Fedora","Amazon","Scientific" : {
      $rubygems_package  = 'rubygems'
      $rubydev_package   = 'ruby-devel'
      $mysql_int_package = 'MySQL-python'
      $mongodb_int_package = 'pymongo'
    }
    default: { fail("Class[datadog]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

}
