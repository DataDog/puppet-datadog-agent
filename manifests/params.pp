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
  $api_key = "your API key"
  $dd_url  = "https://app.datadoghq.com"

  case $operatingsystem {
    "Ubuntu","Debian": {
      $rubygems_package = 'rubygems'
      $rubydev_package =  'ruby-dev'
    }
    "RedHat","CentOS","Fedora": {
      $rubygems_package = 'rubygems'
      $rubydev_packages = 'ruby-devel'
    }
    default: { notify{'Unsupported OS': message => 'The DataDog module only support Red Hat and Ubuntu derivatives'} }
  }
    
}
