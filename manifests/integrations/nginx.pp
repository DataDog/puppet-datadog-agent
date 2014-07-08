# Class: datadog_agent::integrations::nginx
#
# This class will install the necessary configuration for the nginx integration
#
# Parameters:
#   $instances:
#       Array of hashes for all nginx urls and associates tags. See example
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::nginx':
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
class datadog_agent::integrations::nginx(
  $instances = [],
) inherits datadog_agent::params {

  validate_array( $instances )

  file { "${conf_dir}/nginx.yaml":
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::dd_group,
    mode    => 0600,
    content => template('datadog_agent/agent-conf.d/nginx.yaml.erb'),
    notify  => Service[$service_name]
  }
}
