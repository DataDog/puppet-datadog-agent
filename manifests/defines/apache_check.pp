# Class: datadog::check::apache
#
# This define contains a datadog apache health check
#
# Parameters
#   url
#       Apache status URL handled by mod-status
#
#   username
#   password
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#
#   tags
#
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# datadog::check::apache { 'apache': }
#
# datadog::check::apache { 'Status Check': 
#   url      => 'http://example.com/server-status?auto',
#   username => 'status',
#   password => 'hunter1',
# }
#
define datadog::check::apache (
  $url       = 'http://localhost/server-status?auto',
  $username  = undef,
  $password  = undef,
  $tags      = [],
) {

  $apache_check_yaml_file = '/etc/dd-agent/conf.d/apache.yaml'

  if ( !defined( Concat[$apache_check_yaml_file] ) ) {
    concat { $apache_check_yaml_file:
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      notify => Service['datadog-agent'],
    }
  }

  if ( !defined( Concat::Fragment["datadog_apache_check_header"] ) ) {
    concat::fragment { "datadog_apache_check_header":
      target  => $apache_check_yaml_file,
      content => "init_config:\n\ninstances:\n",
      order   => 10,
    }
  }

  concat::fragment { "datadog_apache_check_fragment_$title":
    target  => $apache_check_yaml_file,
    content => template('datadog/apache_check.yaml.erb'),
    order   => 20,
  }

}
