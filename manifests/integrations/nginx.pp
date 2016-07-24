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
# lint:ignore:80chars
class datadog_agent::integrations::nginx(
  $instances = [],
) inherits datadog_agent::params { # lint:ignore:class_inherits_from_params_class

  validate_array($instances)

  file { "${datadog_agent::params::conf_dir}/nginx.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/nginx.yaml.erb'),
    require => Class['datadog_agent'],
    notify  => Service[$datadog_agent::params::service_name]
  }
# lint:endignore
}
