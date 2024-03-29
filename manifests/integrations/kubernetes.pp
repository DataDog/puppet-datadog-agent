# Class: datadog_agent::integrations::kubernetes
#
# This class will install the necessary configuration for the kubernetes integration
#
# Parameters:
#   $url:
#     The URL for kubernetes API
#
#   $tags:
#     optional array of tags
#
#
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::kubernetes' :
#     api_server_url       => 'https://kubernetes:443',
#     apiserver_client_crt => '/etc/ssl/certs/crt',
#     apiserver_client_key => '/etc/ssl/private/key',
#     kubelet_client_crt   => '/etc/ssl/certs/crt',
#     kubelet_client_key   => '/etc/ssl/private/key',
#   }
#
class datadog_agent::integrations::kubernetes(
  $api_server_url = 'Enter_Your_API_url',
  $apiserver_client_crt = '/path/to/crt',
  $apiserver_client_key = '/path/to/key',
  $kubelet_client_crt = '/path/to/crt',
  $kubelet_client_key = '/path/to/key',
  $tags = [],

) inherits datadog_agent::params {
  require ::datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/kubernetes.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/kubernetes.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
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
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_file,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
    content => template('datadog_agent/agent-conf.d/kubernetes.yaml.erb'),
  }
}
