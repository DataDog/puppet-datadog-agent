# Class: datadog_agent::ubuntu_installer
# This class installs and configures the Datadog agent on Debian distributions.
#
# @param api_key String:Your DataDog API Key.
# @param datadog_site String: The site of the Datadog intake to send Agent data to. Defaults to 'datadoghq.com'.
# @param agent_major_version Integer: The major version of the Datadog agent to install. Defaults to 7.
# @param agent_minor_version Optional[String]: The minor version of the Datadog agent to install.
# @param installer_repo_uri Optional[String]: The URI of the installer repository.
# @param release String: The distribution channel to be used for the APT repo. Eg: 'stable' or 'beta'. Default: stable.
# @param skip_apt_key_trusting Boolean: Skip trusting the apt key. Default is false.
# @param manage_agent_install Boolean: Whether Puppet should manage the regular Agent installation. Default is true (inherited from $manage_install).
# @param apt_trusted_d_keyring String: The path to the trusted keyring file.
# @param apt_usr_share_keyring String: The path to the keyring file in /usr/share.
# @param apt_default_keys Hash[String, String]: A hash of default APT keys and their URLs.
# @param apm_instrumentation_enabled Optional[Enum['host', 'docker', 'all']]: Enable APM instrumentation for the specified environment (host, docker, or all).
# @param apm_instrumentation_libraries_str Optional[String]: APM instrumentation libraries as a comma-separated string.
# @param remote_updates Boolean: Whether to enable Agent remote updates. Default: false.
# @param remote_policies Boolean: Whether to enable Agent remote policies. Default: false.
#
class datadog_agent::ubuntu_installer (
  String $api_key = 'your_API_key',
  String $datadog_site = $datadog_agent::params::datadog_site,
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  Optional[String] $agent_minor_version = undef,
  Boolean $manage_agent_install = true,
  Optional[String] $installer_repo_uri = undef,
  String $release = $datadog_agent::params::apt_default_release,
  Boolean $skip_apt_key_trusting = false,
  String $apt_trusted_d_keyring = '/etc/apt/trusted.gpg.d/datadog-archive-keyring.gpg',
  String $apt_usr_share_keyring = '/usr/share/keyrings/datadog-archive-keyring.gpg',
  Hash[String, String] $apt_default_keys = {
    # DATADOG_APT_KEY_CURRENT.public always contains key used to sign current
    # repodata and newly released packages.
    'DATADOG_APT_KEY_CURRENT.public'           => 'https://keys.datadoghq.com/DATADOG_APT_KEY_CURRENT.public',
    # DATADOG_APT_KEY_06462314.public expires in 2033
    'D18886567EABAD8B2D2526900D826EB906462314' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_06462314.public',
    # DATADOG_APT_KEY_C0962C7D.public expires in 2028
    '5F1E256061D813B125E156E8E6266D4AC0962C7D' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_C0962C7D.public',
    # DATADOG_APT_KEY_F14F620E.public expires in 2032
    'D75CEA17048B9ACBF186794B32637D44F14F620E' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_F14F620E.public',
    # DATADOG_APT_KEY_382E94DE.public expires in 2022
    'A2923DFF56EDA6E76E55E492D3A80E30382E94DE' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_382E94DE.public',
  },
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

  # Do not re-install keys as it is already managed in `ubuntu.pp`
  if ! $manage_agent_install {
    if !$skip_apt_key_trusting {
      stdlib::ensure_packages(['gnupg'])

      file { $apt_usr_share_keyring:
        ensure  => file,
        mode    => '0644',
        require => Exec['Start timer'],
      }

      $apt_default_keys.each |String $key_fingerprint, String $key_url| {
        $key_path = "/tmp/${key_fingerprint}"

        file { $key_path:
          owner  => root,
          group  => root,
          mode   => '0600',
          source => $key_url,
        }

        $unless_cmd = @("CMD"/L)
          /usr/bin/gpg --no-default-keyring --keyring ${apt_usr_share_keyring} --list-keys --with-fingerprint --with-colons | grep \
          $(cat /tmp/${key_fingerprint} | gpg --with-colons --with-fingerprint 2>/dev/null | grep 'fpr:' | sed 's|^fpr||' | tr -d ':')
          | CMD

        exec { "ensure key ${key_fingerprint} is imported in APT keyring":
          command => "/bin/cat /tmp/${key_fingerprint} | gpg --import --batch --no-default-keyring --keyring ${apt_usr_share_keyring}",
          # the second part extracts the fingerprint of the key from output like "fpr::::A2923DFF56EDA6E76E55E492D3A80E30382E94DE:"
          unless  => $unless_cmd,
        }
      }
      if ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '16') == -1) or
      ($facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['full'], '9') == -1) {
        file { $apt_trusted_d_keyring:
          mode   => '0644',
          source => "file://${apt_usr_share_keyring}",
        }
      }
    }
  }

  if ($installer_repo_uri != undef) {
    $location = $installer_repo_uri
  } else {
    $location = "[signed-by=${apt_usr_share_keyring}] https://apt.datadoghq.com/"
  }

  # Install APT repository
  apt::source { 'datadog-installer':
    # Installer is located in the same APT repository as the Agent, only within repo 7
    comment  => 'Datadog Installer Repository',
    location => $location,
    release  => $release,
    repos    => '7',
    require  => Exec['Start timer'],
  }

  # Install `datadog-installer` package with latest versions
  package { 'datadog-installer':
    ensure  => 'latest',
    require => [Apt::Source['datadog-installer'], Class['apt::update']],
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
