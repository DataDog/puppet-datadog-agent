# Class: datadog::integrations::nginx
#
# This class will install the necessary configuration for the mongodb integration
#
# Parameters:
# $nginx_host
#    The host where nginx is running
#
# $nginx_port
#    The port on which the nginx status endpoint can be reached
#
# $nginx_status_path
#    The path at which the nginx status endpoint can be reached
#
# $nginx_protocol
#    The protocol under which the nginx status URL can be reached
#
# Sample Usage:
#
#  class { 'datadog::integrations::elasticsearch' :
#    host     => 'localhost',
#    path     => '/nginx_status'
#  }
#
#
class datadog::integrations::nginx(
  $nginx_host = 'localhost',
  $nginx_port = 80,
  $nginx_path = '/nginx_status',
  $nginx_protocol = 'http',
  $tags = []
) inherits datadog::params {

  file { "${conf_dir}/nginx.yaml":
    ensure  => file,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => 0644,
    content => template('datadog/nginx.yaml.erb'),
    notify  => Service[$service_name]
  }
}
