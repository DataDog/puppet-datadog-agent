# Class: datadog_agent::integrations::jmx
#
# This class will install the necessary configuration for the jmx integration
#
# Parameters:
#   $init_config:
#       Hash of inital configuration, consisting of the following keys:
#
#     custom_jar_paths:
#       Array of paths to jars. Optional.
#
#   $instances:
#       Array of instance hashes, consisting of the following keys:
#
#     name:
#       Used in conjunction with jmx_url. Optional.
#     tags:
#       Hash of tags { 'env' =>  'prod' }. Optional.
#     host:
#       The host jmx is running on.
#     port:
#       The JMX port.
#     jmx_url:
#       If the agent needs to connect to a non-default JMX URL, specify it here
#       instead of a host and a port. If you use this you need to specify a ‘name’
#       for the instance. Optional.
#     user:
#       The username for connecting to the running JVM. Optional.
#     password:
#       The password for connecting to the running JVM. Optional.
#     process_name_regex:
#       Instead of specifying a host and port or jmx_url, the agent can
#       connect using the attach api. This requires the JDK to be installed
#       and the path to tools.jar to be set. Optional.
#     tools_jar_path:
#       To be set when process_name_regex is set. Optional.
#     java_bin_path:
#       The path to the Java binary. Should be set if the agent cannot find your java executable. Optional.
#     java_options:
#       Java JVM options. Optional.
#     trust_store_path:
#       The path to the trust store. Should be set if ssl is enabled. Optional.
#     trust_store_password:
#       The trust store password. Should be set if ssl is enabled. Optional.
#     conf:
#       Array of include/exclude hash pairs. Optional.
#       Read http://docs.datadoghq.com/integrations/java/ to learn how to customize it.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::jmx':
#    init_config        => {
#      custom_jar_paths => ['/path/to/custom.jar']
#    },
#    instances  => [{
#      host     => 'localhost',
#      port     => 7199,
#      user     => 'username',
#      password => 'password',
#      jmx_url  => 'service:jmx:rmi:///jndi/rmi://myhost.host:9999/custompath'
#    }],
#  }
#
class datadog_agent::integrations::jmx(
  $init_config = {},
  $instances   = [],
) inherits datadog_agent::params {
  include datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/jmx.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/jmx.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/jmx.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

}
