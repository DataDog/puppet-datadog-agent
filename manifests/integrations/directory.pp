# Class: datadog_agent::integrations::directory
#
# This class will install the necessary config to hook the directory check
#
# Parameters:
#   $directory
#       The directory to gather stats for
#   $tag_name
#       The name used to tag the metrics (directory alias)
#   $pattern
#       The `fnmatch` pattern to use when reading the "directory"'s files. default "*"
#   $recursive
#       Boolean, when true the stats will recurse into directories
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::directory' :
#      directory     => '/mnt/media',
#      tag_name      => 'name',
#      pattern       => '*',
#      recursive     => true,
#  }
class datadog_agent::integrations::directory (
  $directory     = undef,
  $tag_name      = '',
  $pattern       = '*',
  $recursive     = false
) inherits datadog_agent::params {

  if $directory == undef {
    fail('you must specify a directory path within the datadog_agent::integrations::directory class')
  }

  file { "${datadog_agent::params::conf_dir}/directory.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/directory.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
