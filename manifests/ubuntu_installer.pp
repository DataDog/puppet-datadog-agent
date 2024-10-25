# Class: datadog_agent::ubuntu_installer
#
# This class contains the Datadog installer installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu_installer (
  String $api_key = 'your_API_key',
  String $datadog_site = $datadog_agent::params::datadog_site,
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  String $agent_minor_version = '',
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
    command => "echo $(od -An -N8 -tu8 < /dev/urandom | tr -d ' ') > /tmp/datadog_trace_id",
    path    => ['/usr/bin', '/bin'],
    onlyif  => ['which echo', 'which od', 'which tr'],
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
      Package['datadog-signing-keys'],
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
