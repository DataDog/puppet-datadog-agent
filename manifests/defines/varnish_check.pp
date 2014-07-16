# Class: datadog::check::varnish
#
# This define contains a datadog varnish health check
#
# Parameters:
#
#   varnishstat
#       Path to the varnishstat binary
#
#   tags
#       DataDog tags
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# datadog::check::varnish { 'varnish': }
#
# datadog::check::varnish { 'Status Check': 
#   url      => '/usr/bin/varnishstat',
#   tags     => ['env:production'],
# }
#
define datadog::check::varnish (
  $varnishstat = '/usr/bin/varnishstat',
  $tags      = [],
) {

  $varnish_check_yaml_file = '/etc/dd-agent/conf.d/varnish.yaml'

  if ( !defined( Concat[$varnish_check_yaml_file] ) ) {
    concat { $varnish_check_yaml_file:
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      notify => Service['datadog-agent'],
    }
  }

  if ( !defined( Concat::Fragment["datadog_varnish_check_header"] ) ) {
    concat::fragment { "datadog_varnish_check_header":
      target  => $varnish_check_yaml_file,
      content => "init_config:\n\ninstances:\n",
      order   => 10,
    }
  }

  concat::fragment { "datadog_varnish_check_fragment_$title":
    target  => $varnish_check_yaml_file,
    content => template('datadog/varnish_check.yaml.erb'),
    order   => 20,
  }

}
