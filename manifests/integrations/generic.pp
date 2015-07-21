# Class: datadog_agent::integrations::generic
#
# This class will install a configuration file for a integration
#
# Parameters:
#   $integration_name:
#       This will be used for to build the filename, it must correspond to an
#         integration that is supported by dd-agent, see the dd-agent for
#         a current list.
#   $integration_template:
#       A string containing a rendered template.
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::generic':
#   integration_name     => 'custom',
#   integration_template => template(my_custom_template),
# }
#
class datadog_agent::integrations::generic(
  $integration_name     = undef,
  $integration_template = undef,
) inherits datadog_agent::params {

  validate_string($integration_name)
  validate_string($integration_template)

  file { "${datadog_agent::params::conf_dir}/${integration_name}.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => $integration_template,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
