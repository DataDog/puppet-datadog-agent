# Class: datadog_agent::integrations::activemq_xml
#
# This class will install the necessary configuration for the activemq_xml integration
#
# Parameters:
#   $url
#       URL to gather the activemq_xml starts from
#   $username
#       Username to use for authentication - optional
#   $password
#       Password to use for authentication - optional
#   $supress_errors
#      Supress connection errors if URL is expected to be offline at times (eg. standby host)
#   $detailed_queues
#      List of queues to monitor, required if you have more than 300 queues you wish to track.
#   $detailed_topics
#      List of topics to monitor, required if you have more than 300 topics you wish to track.
#   $detailed_subscribers
#      List of subscribers to monitor, required if you have more than 300 subscribers you wish to track.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::activemq_xml' :
#    url     => 'http://localhost:8161',
#    username => 'datadog',
#    password => 'some_pass',
#    supress_errors => false,
#    detailed_queues => ['queue1', 'queue2', 'queue3'],
#    detailed_topics => ['topic1', 'topic2', 'topic3'],
#    detailed_subscribers => ['subscriber1', 'subscriber2', 'subscriber3'],
#  }
#
# Hiera Usage:
#
#   datadog_agent::integrations::activemq_xml::instances:
#     - host: 'http://localhost:8161'
#       username: 'datadog'
#       password: 'some_pass'
#       supress_errors: false
#       detailed_queues: ['queue1', 'queue2', 'queue3'],
#       detailed_topics: ['topic1', 'topic2', 'topic3'],
#       detailed_subscribers: ['subscriber1', 'subscriber2', 'subscriber3'],
#
#
class datadog_agent::integrations::activemq_xml(
  String $url                                   = 'http://localhost:8161',
  Boolean $supress_errors                       = false,
  Optional[String] $username                    = undef,
  Optional[String] $password                    = undef,
  Optional[Array[String]] $detailed_queues      = [],
  Optional[Array[String]] $detailed_topics      = [],
  Optional[Array[String]] $detailed_subscribers = [],
  Optional[Array] $instances                    = undef,
) inherits datadog_agent::params {
  include datadog_agent

  $legacy_dst = "${datadog_agent::conf_dir}/activemq_xml.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/activemq_xml.d/conf.yaml"
    file { $legacy_dst:
      ensure => 'absent'
    }
  } else {
    $dst = $legacy_dst
  }

  if !$instances and $url {
    $_instances = [{
      'url'                  => $url,
      'username'             => $username,
      'password'             => $password,
      'supress_errors'       => $supress_errors,
      'detailed_queues'      => $detailed_queues,
      'detailed_topics'      => $detailed_topics,
      'detailed_subscribers' => $detailed_subscribers,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/activemq_xml.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
