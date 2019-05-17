# Class: datadog_agent::integrations::kong
#
# This class will install the necessary configuration for the Kong integration
#
# Note: if you're Cassandra data-store is large in size the `/status` page may
# take a long time to return.
# <https://github.com/Mashape/kong/issues/1323>
#
# Parameters:
#   $instances:
#       Array of hashes for all Kong instances and associated tags. See example
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::kong':
#     instances => [
#         {
#             'status_url'  => http://localhost:8001/status/',
#         },
#         {
#             'status_url'  => 'http://localhost:8001/status/',
#             'tags' => ['instance:foo'],
#         },
#     ],
#   }
#
class datadog_agent::integrations::kong (
  $instances = [
    {
      'status_url' => 'http://localhost:8001/status/',
      'tags' => []
    }
  ]
) inherits datadog_agent::params {
  include datadog_agent

  $legacy_dst = "${datadog_agent::conf_dir}/kong.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/kong.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
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
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/kong.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
