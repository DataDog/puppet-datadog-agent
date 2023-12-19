# Class: datadog_agent::integrations::kubernetes
#
# This class will install the necessary configuration for the kubernetes integration
#
# Parameters:
#   @param api_server_url
#   @param apiserver_client_crt
#   @param apiserver_client_key
#   @param kubelet_client_crt
#   @param kubelet_client_key
#   @param tags
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
class datadog_agent::integrations::kubernetes (
  String $api_server_url       = 'Enter_Your_API_url',
  String $apiserver_client_crt = '/path/to/crt',
  String $apiserver_client_key = '/path/to/key',
  String $kubelet_client_crt   = '/path/to/crt',
  String $kubelet_client_key   = '/path/to/key',
  Array $tags                  = [],
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/kubernetes.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/kubernetes.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
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
