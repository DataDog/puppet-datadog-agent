# Class: datadog_agent::integrations::nginx
#
# This class will install the necessary configuration for the nginx integration
#
# Parameters:
#   $instances:
#       Array of hashes for all nginx urls and associates tags. See example
#   $logs:
#       (optional) log collection configuration, in the format described here:
#       https://docs.datadoghq.com/integrations/nginx/
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
#         {
#             'type' => 'file',
#             'path' => '/var/log/nginx/access.log',
#             'service' => 'nginx',
#             'source' => 'nginx',
#             'sourcecategory' => 'http_web_access'
#           },
#           {
#             'type' => 'file',
#             'path' => '/var/log/nginx/error.log',
#             'service' => 'nginx',
#             'source' => 'nginx',
#             'sourcecategory' => 'http_web_access'
#         },
#     ],
#   }
#
# Hiera Usage:
#
#   datadog_agent::integrations::nginx::instances:
#       - nginx_status_url: 'http://example.com/nginx_status/'
#       - nginx_status_url: 'http://example2.com:1234/nginx_status/'
#         tags:
#             - 'instance:foo'
#   datadog_agent::integrations::nginx::logs:
#       - type: file
#         path: /var/log/nginx/access.log
#         service: nginx
#         source: nginx
#         sourcecategory: 'http_web_access'
#       - type: file
#         path: /var/log/nginx/error.log
#         service: nginx
#         source: nginx
#         sourcecategory: 'http_web_access'
#

class datadog_agent::integrations::nginx(
  Array $instances = [],
  Optional[Array] $logs = undef,
) inherits datadog_agent::params {
  include datadog_agent

  validate_legacy('Array', 'validate_array', $instances)

  $legacy_dst = "${datadog_agent::conf_dir}/nginx.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/nginx.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/nginx.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
