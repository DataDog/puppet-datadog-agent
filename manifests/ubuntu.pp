# Class: datadog_agent::ubuntu
#
# This class contains the DataDog agent installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu(
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  String $agent_version = $datadog_agent::params::agent_version,
  Optional[String] $agent_repo_uri = undef,
  String $release = $datadog_agent::params::apt_default_release,
  Boolean $skip_apt_key_trusting = false,
  String $agent_flavor = $datadog_agent::params::package_name,
  Optional[String] $apt_trusted_d_keyring = '/etc/apt/trusted.gpg.d/datadog-archive-keyring.gpg',
  Optional[String] $apt_usr_share_keyring = '/usr/share/keyrings/datadog-archive-keyring.gpg',
  Optional[Hash[String, String]] $apt_default_keys = {
    'DATADOG_APT_KEY_CURRENT.public'           => 'https://keys.datadoghq.com/DATADOG_APT_KEY_CURRENT.public',
    '5F1E256061D813B125E156E8E6266D4AC0962C7D' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_C0962C7D.public',
    'D75CEA17048B9ACBF186794B32637D44F14F620E' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_F14F620E.public',
    'A2923DFF56EDA6E76E55E492D3A80E30382E94DE' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_382E94DE.public',
  },
) inherits datadog_agent::params {

  if $agent_version =~ /^[0-9]+\.[0-9]+\.[0-9]+((?:~|-)[^0-9\s-]+[^-\s]*)?$/ {
    $platform_agent_version = "1:${agent_version}-1"
  }
  else {
    $platform_agent_version = $agent_version
  }

  case $agent_major_version {
    5 : { $repos = 'main' }
    6 : { $repos = '6' }
    7 : { $repos = '7' }
    default: { fail('invalid agent_major_version') }
  }

  if !$skip_apt_key_trusting {
    ensure_packages(['gnupg'])

    file { $apt_usr_share_keyring:
      ensure => file,
      mode   => '0644',
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

    if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '16') == -1) or
        ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '9') == -1) {
      file { $apt_trusted_d_keyring:
        mode   => '0644',
        source => "file://${apt_usr_share_keyring}",
      }
    }
  }

  if ($agent_repo_uri != undef) {
    $location = $agent_repo_uri
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

  apt::source { 'datadog':
    comment  => 'Datadog Agent Repository',
    location => $location,
    release  => $release,
    repos    => $repos,
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$agent_flavor],
  }

  package { $agent_flavor:
    ensure  => $platform_agent_version,
    require => [Apt::Source['datadog'],
                Class['apt::update']],
  }

  package { 'datadog-signing-keys':
    ensure  => 'latest',
    require => [Apt::Source['datadog'],
                Class['apt::update']],
  }
}
