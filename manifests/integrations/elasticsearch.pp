# Class: datadog::integrations::elasticsearch
#
# This class will install the necessary configuration for the elasticsearch integration
# Parameters:
#   none
#
# Sample Usage:
#
#   class { 'datadog::integrations::elasticsearch' :
#   }
#
class datadog::integrations::elasticsearch inherits datadog::params {

  file { "${datadog::conf_dir}/elastic.yaml":
    ensure  => file,
    owner   => $datadog::dd_user,
    group   => $datadog::dd_group,
    mode    => '0644',
    source  => 'puppet:///modules/datadog/elastic.yaml',
    require => Package[ 'datadog-agent' ],
    notify  => Service[ $datadog::service_name ],
  }
}
