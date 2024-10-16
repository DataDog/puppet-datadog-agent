# Class: datadog_agent::ubuntu_installer
#
# This class contains the Datadog installer installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu_installer (
  String $api_key = 'your_API_key',
  String $datadog_site = $datadog_agent::params::datadog_site,
  Optional[String] $installer_repo_uri = undef,
  String $release = $datadog_agent::params::apt_default_release,
  Boolean $skip_apt_key_trusting = false,
  Optional[String] $apt_trusted_d_keyring = '/etc/apt/trusted.gpg.d/datadog-archive-keyring.gpg',
  Optional[String] $apt_usr_share_keyring = '/usr/share/keyrings/datadog-archive-keyring.gpg',
  Optional[Hash[String, String]] $apt_default_keys = {
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
  Optional[String] $remote_updates = undef,
) inherits datadog_agent::params {
  # Generate installer trace ID as a random 64-bit integer (Puppet does not support 128-bit integers)
  # Note: we cannot use fqdn_rand as the seed is dependent on the node, meaning the same trace ID would be generated on each run (for the same node)
  # -An: no address, no leading 0s
  # -N8: read 8 bytes
  # -tu8: unsigned integer, 8 bytes (64 bits)
  exec { 'Generate trace ID':
    command => 'echo $(od -An -N8 -tu8 /dev/urandom) > /tmp/datadog_trace_id',
    path    => ['/usr/bin', '/bin'],
    onlyif  => ['which echo', 'which od'],
  }

  # Start timer (note: Puppet is not able to measure time directly as it's against its paradigm)
  exec { 'Start timer':
    command => 'date +%s%N > /tmp/puppet_start_time',
    path    => ['/usr/bin', '/bin'],
    require => Exec['Generate trace ID'],
  }

  if !$skip_apt_key_trusting {
    ensure_packages(['gnupg'])

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

      exec { "ensure key ${key_fingerprint} is imported in APT keyring":
        command => "/bin/cat /tmp/${key_fingerprint} | gpg --import --batch --no-default-keyring --keyring ${apt_usr_share_keyring}",
        # the second part extracts the fingerprint of the key from output like "fpr::::A2923DFF56EDA6E76E55E492D3A80E30382E94DE:"
        unless  => @("CMD"/L)
          /usr/bin/gpg --no-default-keyring --keyring ${apt_usr_share_keyring} --list-keys --with-fingerprint --with-colons | grep \
          $(cat /tmp/${key_fingerprint} | gpg --with-colons --with-fingerprint 2>/dev/null | grep 'fpr:' | sed 's|^fpr||' | tr -d ':')
          | CMD
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

  if ($installer_repo_uri != undef) {
    $location = $installer_repo_uri
  } else {
    $location = "[signed-by=${apt_usr_share_keyring}] https://apt.datadoghq.com/"
  }

  apt::source { 'datadog-beta':
    ensure => absent,
  }

  apt::source { 'datadog5':
    ensure => absent,
  }

  apt::source { 'datadog6':
    ensure => absent,
  }

  # Install APT repository
  apt::source { 'datadog':
    # Installer is located in the same APT repository as the Agent, only within repo 7
    comment  => 'Datadog Agent Repository',
    location => $location,
    release  => $release,
    repos    => '7',
    require  => Exec['Start timer'],
  }

  # Install `datadog-installer` and `datadog-signing-keys` packages with latest versions
  package { 'datadog-installer':
    ensure  => 'latest',
    require => [Apt::Source['datadog'], Class['apt::update']],
  }

  package { 'datadog-signing-keys':
    ensure  => 'latest',
    require => [Apt::Source['datadog'], Class['apt::update']],
  }

  # Bootstrap the installer (idempotent per Fleet Automation team)
  exec { 'Bootstrap the installer':
    command     => '/usr/bin/env DATADOG_TRACE_ID=$(cat /tmp/datadog_trace_id) DATADOG_PARENT_ID=$(cat /tmp/datadog_trace_id) /usr/bin/datadog-bootstrap bootstrap',
    environment => [
      "DD_SITE=${datadog_site}",
      "DD_API_KEY=${api_key}",
      "DD_REMOTE_UPDATES=${remote_updates}",
      "DD_APM_INSTRUMENTATION_ENABLED=${apm_instrumentation_enabled}",
      "DD_APM_INSTRUMENTATION_LIBRARIES=${apm_instrumentation_libraries_str}",
    ],
    require     => [Package['datadog-installer'], Package['datadog-signing-keys']],
  }

  # Check if installer owns the Datadog Agent package
  exec {
    'Check if installer owns the Datadog Agent package':
      command     => '/usr/bin/datadog-installer is-installed datadog-agent',
      environment => [
        "DD_API_KEY=${api_key}",
      ],
      # TODO(FA): Agent package is downloaded only if remote_updates is enabled, so we allow return code 10
      returns     => [0, 10],
      require     => Exec['Bootstrap the installer'],
  }

  # Check if installer owns APM libraries
  if $apm_instrumentation_libraries_str != '' {
    $apm_instrumentation_libraries_str.split(',').each |$library| {
      exec { "Check if installer owns APM library ${library}":
        command     => "/usr/bin/datadog-installer is-installed datadog-apm-library-${library}",
        environment => [
          "DD_API_KEY=${api_key}",
        ],
        require     => Exec['Bootstrap the installer'],
      }
    }
  }

  # Stop timer
  exec { 'End timer':
    command => 'date +%s%N > /tmp/puppet_stop_time',
    path    => ['/usr/bin', '/bin'],
    # TO DO: replace after checking if installer owns APM package and libraries
    require => Exec['Check if installer owns the Datadog Agent package'],
  }

  if $remote_updates {
    $packages_to_install = "datadog-agent,${apm_instrumentation_libraries_str}"
  } else {
    $packages_to_install = $apm_instrumentation_libraries_str
  }
  # TO DO: telemetry (trace) & logs
  class { 'datadog_agent::installer_params':
    api_key      => $api_key,
    datadog_site => $datadog_site,
    packages_to_install => $packages_to_install,
    require      => Exec['End timer'],
  }
}
