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
  $conf_dir     = "/etc/dd-agent/conf.d"
  $dd_user      = "dd-agent"
  $dd_group     = "root"
  $service_name = "datadog-agent"

  case $operatingsystem {
    "Ubuntu","Debian" : {
      $rubydev_package   =  'ruby-dev'
      $process_int_package = 'python-psutil'
      $mysql_int_package = 'python-mysqldb'
      $mongo_int_package = 'python-pymongo'
      $redis_int_package = 'python-redis'
    }
    "RedHat","CentOS","Fedora","Amazon","Scientific" : {
      $rubydev_package   = 'ruby-devel'
      $process_int_package = 'python-psutil'
      $mysql_int_package = 'MySQL-python'
      $mongo_int_package = 'python-pymongo'
      $redis_int_package = 'python-redis'
    }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

}
