# Class: datadog_agent::suse
#
# This class contains the DataDog agent installation mechanism for SUSE distributions
#

class datadog_agent::suse(
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  String $agent_version = $datadog_agent::params::agent_version,
  String $release = $datadog_agent::params::apt_default_release,
  Optional[String] $agent_repo_uri = undef,
  String $agent_flavor = $datadog_agent::params::package_name,
) inherits datadog_agent::params {

  $all_keys = [
    'https://yum.datadoghq.com/DATADOG_RPM_KEY.public',
    'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
    'https://yum.datadoghq.com/DATADOG_RPM_KEY_20200908.public',
  ]

  case $agent_major_version {
      5 : { fail('Agent v5 package not available in SUSE') }
      6 : { $gpgkeys = $all_keys }
      7 : { $gpgkeys = $all_keys[1,2] }
      default: { fail('invalid agent_major_version') }
  }

  if ($agent_repo_uri != undef) {
    $baseurl = $agent_repo_uri
  } else {
    $baseurl = "https://yum.datadoghq.com/suse/${release}/${agent_major_version}/${::architecture}"
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$agent_flavor],
  }

  # We need to install GPG keys manually since zypper will autoreject new keys
  # We download each key and import it using rpm --import
  $gpgkeys.each |String $key_url| {
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
    gpgkey       => join($gpgkeys, "	"),
    keeppackages => 1,
  }

  package { $agent_flavor:
    ensure  => $agent_version,
  }

}
