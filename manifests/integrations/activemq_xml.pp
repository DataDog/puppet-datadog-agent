# Class: datadog_agent::integrations::activemq_xml
#
# This class will install the necessary configuration for the activemq_xml integration.
#
# See the sample activemq.d/conf.yaml for all available configuration options.
# https://github.com/DataDog/integrations-core/blob/master/activemq/datadog_checks/activemq/data/conf.yaml.example 
#
# See the metrics.yaml file for the list of default collected metrics.
# https://github.com/DataDog/integrations-core/blob/master/activemq/datadog_checks/activemq/data/metrics.yaml
#
# This check has a limit of 350 metrics per instance. If you require 
# additional metrics, contact Datadog Support at https://docs.datadoghq.com/help/
#
# Parameters:
#   $url
#       ActiveMQ administration web URL to gather the activemq_xml stats from.
#   $username
#       Username to use for authentication - optional
#   $password
#       Password to use for authentication - optional
#   $suppress_errors
#      Supress connection errors if URL is expected to be offline at times (eg. standby host) - optional
#   $detailed_queues
#      List of queues to monitor, required if you have more than 300 queues you wish to track, otherwise optional.
#   $detailed_topics
#      List of topics to monitor, required if you have more than 300 topics you wish to track, otherwise optional.
#   $detailed_subscribers
#      List of subscribers to monitor, required if you have more than 300 subscribers you wish to track, otherwise optional.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::activemq_xml' :
#    url     => 'http://localhost:8161',
#    username => 'datadog',
#    password => 'some_pass',
#    suppress_errors => false,
#    detailed_queues => ['queue1', 'queue2', 'queue3'],
#    detailed_topics => ['topic1', 'topic2', 'topic3'],
#    detailed_subscribers => ['subscriber1', 'subscriber2', 'subscriber3'],
#  }
#
# Hiera Usage:
#
#   datadog_agent::integrations::activemq_xml::instances:
#     - url: 'http://localhost:8161'
#       username: 'datadog'
#       password: 'some_pass'
#       suppress_errors: false
#       detailed_queues: ['queue1', 'queue2', 'queue3']
#       detailed_topics: ['topic1', 'topic2', 'topic3']
#       detailed_subscribers: ['subscriber1', 'subscriber2', 'subscriber3']
#
#
class datadog_agent::integrations::activemq_xml (
  String $url                         = 'http://localhost:8161',
  Boolean $supress_errors             = false, # keep for backwards-compatibility
  Boolean $suppress_errors            = $supress_errors,
  Optional[String] $username          = undef,
  Optional[String] $password          = undef,
  Array[String] $detailed_queues      = [],
  Array[String] $detailed_topics      = [],
  Array[String] $detailed_subscribers = [],
  Optional[Array] $instances          = undef,
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/activemq_xml.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

  if !$instances and $url {
    $_instances = [{
        'url'                  => $url,
        'username'             => $username,
        'password'             => $password,
        'suppress_errors'      => $suppress_errors,
        'detailed_queues'      => $detailed_queues,
        'detailed_topics'      => $detailed_topics,
        'detailed_subscribers' => $detailed_subscribers,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/activemq_xml.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
