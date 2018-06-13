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
  Array $instances = [],
) inherits datadog_agent::params {
  include datadog_agent


  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/nginx.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/nginx.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/nginx.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
