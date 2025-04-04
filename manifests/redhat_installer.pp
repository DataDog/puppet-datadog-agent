# Class: datadog_agent::redhat_installer
# This class installs and configures the Datadog agent on RedHat-based systems.
#
# @param api_key Sensitive[String]:Your DataDog API Key.
# @param datadog_site String: The site of the Datadog intake to send Agent data to. Defaults to 'datadoghq.com'.
# @param agent_major_version Integer: The major version of the Datadog agent to install. Defaults to 7.
# @param agent_minor_version Optional[String]: The minor version of the Datadog agent to install.
# @param installer_repo_uri Optional[String]: The URI of the installer repository.
# @param rpm_repo_gpgcheck Optional[Boolean]: Whether to check the GPG signature of the repository.
# @param apm_instrumentation_enabled Optional[Enum['host', 'docker', 'all']]: Enable APM instrumentation for the specified environment (host, docker, or all).
# @param apm_instrumentation_libraries_str Optional[String]: APM instrumentation libraries as a comma-separated string.
# @param remote_updates Boolean: Whether to enable Agent remote updates. Default: false.
# @param remote_policies Boolean: Whether to enable Agent remote policies. Default: false.
#
class datadog_agent::redhat_installer (
  Sensitive[String] $api_key = Sensitive('your_API_key'),
  String $datadog_site = $datadog_agent::params::datadog_site,
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  Optional[String] $agent_minor_version = undef,
  Optional[String] $installer_repo_uri = undef,
  Optional[Boolean] $rpm_repo_gpgcheck = undef,
  Optional[Enum['host', 'docker', 'all']] $apm_instrumentation_enabled = undef,
  Optional[String] $apm_instrumentation_libraries_str = undef,
  Boolean $remote_updates = $datadog_agent::params::remote_updates,
  Boolean $remote_policies = $datadog_agent::params::remote_policies,
) inherits datadog_agent::params {
  # Generate installer trace ID as a random 64-bit integer (Puppet does not support 128-bit integers)
  # Note: we cannot use fqdn_rand as the seed is dependent on the node, meaning the same trace ID would be generated on each run (for the same node)
  # -An: no address, no leading 0s
  # -N8: read 8 bytes
  # -tu8: unsigned integer, 8 bytes (64 bits)
  exec { 'Generate trace ID':
    command => "echo $(od -An -N8 -tu8 < /dev/urandom | tr -d ' ') > /tmp/datadog_trace_id",
    path    => ['/usr/bin', '/bin'],
    onlyif  => '/bin/sh -c "command -v tr && command -v od && command -v echo"',
  }

  # Start timer (note: Puppet is not able to measure time directly as it's against its paradigm)
  exec { 'Start timer':
    command => 'date +%s%N > /tmp/puppet_start_time',
    path    => ['/usr/bin', '/bin'],
    require => Exec['Generate trace ID'],
  }

  # Define the GPG keys to use for the repository
  # We only use the latest key and previous key since the installer is signed with the latest key and the agent might be signed with the previous key.
  $all_keys = [
    'https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public',
    # Previous, EOL September 2024
    'https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public',
    # Current
    'https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public',
    # Future, active from April 2028
    'https://keys.datadoghq.com/DATADOG_RPM_KEY_4F09D16B.public',
  ]

  if ($rpm_repo_gpgcheck != undef) {
    $repo_gpgcheck = $rpm_repo_gpgcheck
  } else {
    if $installer_repo_uri == undef {
      case $facts['os']['name'] {
        'RedHat', 'CentOS', 'OracleLinux': {
          # disable repo_gpgcheck on 8.1 because of https://bugzilla.redhat.com/show_bug.cgi?id=1792506
          if $facts['os']['release']['full'] =~ /^8.1/ {
            $repo_gpgcheck = false
          } else {
            $repo_gpgcheck = true
          }
        }
        default: {
          $repo_gpgcheck = true
        }
      }
    } else {
      $repo_gpgcheck = false
    }
  }

  if ($installer_repo_uri != undef) {
    $baseurl = $installer_repo_uri
  } else {
    # Unlike the Agent package, the installer is only within the stable repository, version 7
    # Thus, no differentiation based on Agent major version.
    $baseurl = "https://yum.datadoghq.com/stable/7/${facts['os']['architecture']}/"
  }

  yumrepo { 'datadog-installer':
    enabled       => 1,
    gpgcheck      => 1,
    gpgkey        => join($all_keys, "\n       "),
    repo_gpgcheck => $repo_gpgcheck,
    descr         => 'Datadog, Inc.',
    baseurl       => $baseurl,
    require       => Exec['Start timer'],
  }

  # Install `datadog-installer` package with latest versions
  package { 'datadog-installer':
    ensure  => 'latest',
    require => Yumrepo['datadog-installer'],
  }

  # Bootstrap the installer
  exec { 'Bootstrap the installer':
    # "Hack" to pass the trace ID at runtime instead of compile time
    command     => '/usr/bin/env DATADOG_TRACE_ID=$(cat /tmp/datadog_trace_id) DATADOG_PARENT_ID=$(cat /tmp/datadog_trace_id) /usr/bin/datadog-bootstrap bootstrap',
    environment => [
      "DD_SITE=${datadog_site}",
      "DD_API_KEY=${api_key}",
      "DD_AGENT_MAJOR_VERSION=${agent_major_version}",
      "DD_AGENT_MINOR_VERSION=${agent_minor_version}",
      "DD_REMOTE_UPDATES=${remote_updates}",
      "DD_REMOTE_POLICIES=${remote_policies}",
      "DD_APM_INSTRUMENTATION_ENABLED=${apm_instrumentation_enabled}",
      "DD_APM_INSTRUMENTATION_LIBRARIES=${apm_instrumentation_libraries_str}",
    ],
    require     => Package['datadog-installer'],
  }

  # Check if installer owns the Datadog Agent package
  exec {
    'Check if installer owns the Datadog Agent package':
      command     => '/usr/bin/datadog-installer is-installed datadog-agent',
      environment => [
        "DD_SITE=${datadog_site}",
        "DD_API_KEY=${api_key}",
      ],
      # We allow 0, 10 (package not installed)
      returns     => [0, 10],
      require     => Exec['Bootstrap the installer'],
  }

  # Check if installer owns APM libraries
  if $apm_instrumentation_libraries_str != '' {
    $apm_instrumentation_libraries_str.split(',').each |$library| {
      exec { "Check if installer owns APM library ${library}":
        command     => "/usr/bin/datadog-installer is-installed datadog-apm-library-${library}",
        environment => [
          "DD_SITE=${datadog_site}",
          "DD_API_KEY=${api_key}",
        ],
        # We allow 0, 10 (package not installed)
        returns     => [0, 10],
        require     => Exec['Bootstrap the installer'],
      }
    }
  }

  # Stop timer
  exec { 'End timer':
    command => 'date +%s%N > /tmp/puppet_stop_time',
    path    => ['/usr/bin', '/bin'],
    require => Exec['Bootstrap the installer'],
  }

  if $remote_updates {
    $packages_to_install = "datadog-agent,${apm_instrumentation_libraries_str}"
  } else {
    $packages_to_install = $apm_instrumentation_libraries_str
  }
  class { 'datadog_agent::installer_telemetry':
    api_key             => $api_key,
    datadog_site        => $datadog_site,
    packages_to_install => $packages_to_install,
    require             => Exec['End timer'],
  }
}
