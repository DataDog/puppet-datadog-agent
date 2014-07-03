# Class: datadog::integrations::nginx
#
# This class will install the necessary configuration for the nginx integration
#
# Parameters:
#   $instances:
#       Array of hashes for all nginx urls and associates tags. See example
#
# Sample Usage:
#
#   class { 'datadog::integrations::nginx':
#     instances => [
#         {
#             'nginx_status_url'  => 'http://example.com/nginx_status/',
#         },
#         {
#             'nginx_status_url'  => 'http://example2.com:1234/nginx_status/',
#             'tags' => ['instance:foo'],
#         },
#     ],
#   }
#
#
#
class datadog::integrations::nginx(
  $instances = [],
) inherits datadog::params {

  validate_array( $instances )

  file { "${conf_dir}/nginx.yaml":
    ensure  => file,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => 0600,
    content => template('datadog/agent-conf.d/nginx.yaml.erb'),
    notify  => Service[$service_name]
  }
}
