# Class: datadog::check::process
#
# This define contains a datadog process health check
#
# Parameters
#   search_strings
#       LIST OF STRINGS If one of the element in the list matches,
#       return the counter of all the processes that contain the string
#
#   exact_match
#       True/False, default to False, if you want to look for an arbitrary
#       string, use exact_match: False, unless use the exact base name of the process
#
#   cpu_check_interval
#       CPU percent check interval: 0.1 - 1.0 sec. More time - more precise
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# datadog::check::process { 'liferay': 
#   search_string => ['java', 'apache'],
#   exact_match   => true,
# }
#
define datadog::check::process (
  $search_strings     = undef,
  $exact_match        = false,
  $cpu_check_interval = undef,
) {

  if $search_strings == undef {
    fail("you must specify at least on search_string to Datadog::Check::Process[$title]")
  }

  if ! defined( Package['python-psutil'] ) {
    package { 'python-psutil':
      ensure => present,
    }
  }

  $process_check_yaml_file = '/etc/dd-agent/conf.d/process.yaml'

  if ( !defined( Concat[$process_check_yaml_file] ) ) {
    concat { $process_check_yaml_file:
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      notify => Service['datadog-agent'],
    }
  }

  if ( !defined( Concat::Fragment["datadog_process_check_header"] ) ) {
    concat::fragment { "datadog_process_check_header":
      target  => $process_check_yaml_file,
      content => "init_config:\n\ninstances:\n",
      order   => 10,
    }
  }

  concat::fragment { "datadog_process_check_fragment_$title":
    target  => $process_check_yaml_file,
    content => template('datadog/process_check.yaml.erb'),
    order   => 20,
  }

}
