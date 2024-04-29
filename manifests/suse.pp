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
  Optional[Boolean] $rpm_repo_gpgcheck = undef,
) inherits datadog_agent::params {

  $current_key = 'https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public'
  $all_keys = [
    $current_key,
    'https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public',
    'https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public',
    'https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
  ]
  #In this regex, version '1:6.15.0~rc.1-1' would match as $1='1:', $2='6', $3='15', $4='0', $5='~rc.1', $6='1'
  if $agent_version =~ /([0-9]+:)?([0-9]+)\.([0-9]+)\.([0-9]+)((?:~|-)[^0-9\s-]+[^-\s]*)?(?:-([0-9]+))?/ or $agent_version == 'latest' {
      if $agent_major_version > 5 and ($agent_version == 'latest' or 0 + $3 > 35) {
        $keys_to_use = $all_keys[0,3]
      } else {
        $keys_to_use = $all_keys
      }
  } else {
    $keys_to_use = $all_keys
  }

  if ($rpm_repo_gpgcheck != undef) {
    $repo_gpgcheck = $rpm_repo_gpgcheck
  } else {
    if ($agent_repo_uri == undef) {
      $repo_gpgcheck = true
    } else {
      $repo_gpgcheck = false
    }
  }

  case $agent_major_version {
      5 : { fail('Agent v5 package not available in SUSE') }
      6 : { $gpgkeys = $keys_to_use }
      7 : { $gpgkeys = $keys_to_use }
      default: { fail('invalid agent_major_version') }
  }

  if ($agent_repo_uri != undef) {
    $baseurl = $agent_repo_uri
  } else {
    $baseurl = "https://yum.datadoghq.com/suse/${release}/${agent_major_version}/${facts['os']['architecture']}"
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

  exec { 'ensure key 4172A230 is removed from the RPM database':
    command => '/bin/rpm --erase gpg-pubkey-4172a230-55dd14f6',
    onlyif  => '/bin/rpm -q gpg-pubkey-4172a230-55dd14f6',
  }

  zypprepo { 'datadog':
    baseurl      => $baseurl,
    enabled      => 1,
    autorefresh  => 1,
    name         => 'datadog',
    gpgcheck     => 1,
    # zypper on SUSE < 15 only understands a single gpgkey value
    gpgkey       => (Float($facts['os']['release']['full']) >= 15.0) ? { true => join($gpgkeys, "\n       "), default => $current_key },
    # TODO: when updating zypprepo to 4.0.0, uncomment the repo_gpgcheck line
    # For now, we can leave this commented, as zypper by default does repodata
    # signature checks if the repomd.xml.asc is present, so repodata checks
    # are effective for most users anyway. We'll make this explicit when we
    # update zypprepo version.
    # repo_gpgcheck => $repo_gpgcheck,
    keeppackages => 1,
  }

  package { $agent_flavor:
    ensure  => $agent_version,
  }

}
