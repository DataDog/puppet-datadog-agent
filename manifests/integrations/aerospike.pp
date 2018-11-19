# Class: datadog_agent::integrations::aerospike
#
# This class will install the necessary config to hook the aerospike in the agent
#
#
# Sample Usage:
#
# See files/agent-conf.d/aerospike.yaml.example for metric names
#
# Add a class for each check instance:
#
# class { 'datadog_agent::integrations::aerospike':
#   host => '127.0.0.1',
#   port => 3003,
#   metrics => ['migrate_rx_objs', 'migrate_tx_objs'],
#   namespace_metrics => ['free-pct-disk', 'free-pct-memory'],
# }
#
# Add multiple instances in one class declaration:
#
# class { 'datadog_agent::integrations::aerospike':
#   instances => [{
#     'host' => '127.0.0.1',
#     'port' => 3003,
#     'metrics' => ['migrate_rx_objs', 'migrate_tx_objs'],
#     'namespace_metrics' => ['free-pct-disk', 'free-pct-memory'],
#     },
#     (...)
#   ]
# }

class datadog_agent::integrations::aerospike (
  Optional[String] $host = undef,
  Optional[Integer] $port = undef,
  Optional[Array[String]] $metrics = undef,
  Optional[Array[String]] $namespace_metrics = undef,
  Optional[Array[Struct[{
    host              => String,
    port              => Optional[Integer],
    metrics           => Optional[Array[String]],
    namespace_metrics => Optional[Array[String]],
  }]]] $instances = undef,
  Array[String] $tags = [],
) inherits datadog_agent::params {

  include datadog_agent

  if !$::datadog_agent::agent5_enable {
    $dst_conf = "${datadog_agent::conf6_dir}/aerospike.d/conf.yaml"
    $dst_conf_example = "${datadog_agent::conf6_dir}/aerospike.d/conf.yaml.example"
    $dst_checks_dir = "${datadog_agent::checks6_dir}"
  } else {
    $dst_conf = "${datadog_agent::conf_dir}/aerospike.yaml"
    $dst_conf_example = "${datadog_agent::conf_dir}/aerospike.yaml.example"
    $dst_checks_dir = "${datadog_agent::checks_dir}"
  }

  if !$instances and $host {
    $_instances = [{
      'host'              => $host,
      'port'              => $port,
      'metrics'           => $metrics,
      'namespace_metrics' => $namespace_metrics,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  file { $dst_conf_example:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0640',
    source  => 'puppet:///modules/datadog_agent/agent-conf.d/aerospike.yaml.example',
    require => Package[$datadog_agent::params::package_name],
  }

  file { $dst_conf:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/aerospike.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }

  file { "${dst_checks_dir}/aerospike.py":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0640',
    source  => 'puppet:///modules/datadog_agent/agent-checks.d/aerospike.py',
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }

}
