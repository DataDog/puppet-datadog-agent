# Class: datadog_agent::integrations::docker_daemon
#
# This class will install the necessary configuration for the docker integration
#
# Parameters:
#   $url:
#     The URL for docker API
#
#   $tags:
#     optional array of tags
#
#   $group:
#     optional name of docker group to add dd-agent user too
#
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::docker_daemon' :
#     url           => 'unix://var/run/docker.sock',
#   }
#
class datadog_agent::integrations::docker_daemon(
  $url = 'unix://var/run/docker.sock',
  $tags = [],
  $group = 'dd-agent',
  $collect_labels_as_tags = '["appName", "project", "runtime", "runtimeVersion", "webserver"]',
) inherits datadog_agent::params {
  include datadog_agent

  user { 'create-dd-agent-user':
    name    => "$dd_user",
    ensure  => 'present',
    gid     => 'dd-agent',
    groups  => ['root', 'docker']
  }

  group { 'create-docker-group':
    name    => 'docker',
    ensure  => 'present',
    before  => User['create-dd-agent-user']
  }

  group { 'create-dd-agent-group':
    name    => 'dd-agent',
    ensure  => 'present',
    before  => User['create-dd-agent-user']
  }

  exec { 'dd-agent-should-be-in-dd-agent-group':
    command => "/usr/sbin/usermod -aG ${group} ${datadog_agent::params::dd_user}",
    unless  => "/bin/cat /etc/group | grep '^${group}:' | grep -qw ${datadog_agent::params::dd_user}",
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

  file { "${datadog_agent::params::conf_dir}/docker.yaml":
    ensure => 'absent'
  }

  file { "${datadog_agent::params::conf_dir}/docker_daemon.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/docker_daemon.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
