# Class: datadog_agent::suse_installer
# This class installs and configures the Datadog agent on RedHat-based systems.
#
# @param api_key String:Your DataDog API Key. Please replace with your key value.
# @param datadog_site String: The site of the Datadog intake to send Agent data to. Defaults to 'datadoghq.com'.
# @param agent_major_version Integer: The major version of the Datadog agent to install. Defaults to 7.
# @param agent_minor_version Optional[String]: The minor version of the Datadog agent to install.
# @param installer_repo_uri Optional[String]: The URI of the installer repository.
# @param rpm_repo_gpgcheck Optional[Boolean]: Whether to check the GPG signature of the repository.
# @param apm_instrumentation_enabled Optional[Enum['host', 'docker', 'all']]: Enable APM instrumentation for the specified environment (host, docker, or all).
# @param apm_instrumentation_libraries_str Optional[String]: APM instrumentation libraries as a comma-separated string.
# @param remote_updates Optional[String]: Whether to enable remote updates.
#
class datadog_agent::suse_installer (
  String $api_key = 'your_API_key',
  String $datadog_site = $datadog_agent::params::datadog_site,
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  Optional[String] $agent_minor_version = undef,
  Optional[String] $installer_repo_uri = undef,
  Optional[Boolean] $rpm_repo_gpgcheck = undef,
  Optional[Enum['host', 'docker', 'all']] $apm_instrumentation_enabled = undef,
  Optional[String] $apm_instrumentation_libraries_str = undef,
  Optional[String] $remote_updates = undef,
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
  ]

  if ($rpm_repo_gpgcheck != undef) {
    $repo_gpgcheck = $rpm_repo_gpgcheck
  } else {
    if ($installer_repo_uri == undef) {
      $repo_gpgcheck = true
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

  # We need to install GPG keys manually since zypper will autoreject new keys
  # We download each key and import it using rpm --import
  $all_keys.each |String $key_url| {
    $key_name = split($key_url, '/')
    $key_path = "/tmp/${key_name[-1]}"

    file { $key_path:
      owner  => root,
      group  => root,
      mode   => '0600',
      source => $key_url,
    }

    exec { "install-${key_name}":
      command => "/bin/rpm --import ${key_path}",
    }
  }

  zypprepo { 'datadog':
    baseurl      => $baseurl,
    enabled      => 1,
    autorefresh  => 1,
    name         => 'datadog',
    gpgcheck     => 1,
    # zypper on SUSE < 15 only understands a single gpgkey value
    gpgkey       => (Float($facts['os']['release']['full']) >= 15.0) ? { true => join($all_keys, "\n       "), default => 'https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public' },
    # TODO: when updating zypprepo to 4.0.0, uncomment the repo_gpgcheck line
    # For now, we can leave this commented, as zypper by default does repodata
    # signature checks if the repomd.xml.asc is present, so repodata checks
    # are effective for most users anyway. We'll make this explicit when we
    # update zypprepo version.
    # repo_gpgcheck => $repo_gpgcheck,
    keeppackages => 1,
    require      => Exec['Start timer'],
  }

  # Install `datadog-installer` package with latest versions
  package { 'datadog-installer':
    ensure  => 'latest',
    require => Zypprepo['datadog'],
  }

  file { 'Bootstrap and is-installed script templating':
    ensure  => file,
    path    => '/tmp/datadog_installer_bootstrap.sh',
    content => epp('datadog_agent/installer/installer_bootstrap.sh.epp', {
        'datadog_site'                      => $datadog_site,
        'api_key'                           => $api_key,
        'agent_major_version'               => $agent_major_version,
        'agent_minor_version'               => $agent_minor_version,
        'remote_updates'                    => $remote_updates,
        'apm_instrumentation_enabled'       => $apm_instrumentation_enabled,
        'apm_instrumentation_libraries_str' => $apm_instrumentation_libraries_str,
      }
    ),
    mode    => '0744',
  }

  exec { 'Run bootstrap script':
    command => 'bash /tmp/datadog_installer_bootstrap.sh ; rm -f /tmp/datadog_installer_bootstrap.sh',
    path    => ['/usr/bin', '/bin'],
    require => [
      File['Bootstrap and is-installed script templating'],
      Package['datadog-installer'],
    ],
  }

  # Stop timer
  exec { 'End timer':
    command => 'date +%s%N > /tmp/puppet_stop_time',
    path    => ['/usr/bin', '/bin'],
    require => Exec['Run bootstrap script'],
  }

  if $remote_updates {
    $packages_to_install = "datadog-agent,${apm_instrumentation_libraries_str}"
  } else {
    $packages_to_install = $apm_instrumentation_libraries_str
  }
  class { 'datadog_agent::installer_params':
    api_key      => $api_key,
    datadog_site => $datadog_site,
    packages_to_install => $packages_to_install,
    require      => Exec['End timer'],
  }
}