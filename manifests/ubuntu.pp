# Class: datadog_agent::ubuntu
#
# This class contains the DataDog agent installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu(
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  String $apt_key = 'A2923DFF56EDA6E76E55E492D3A80E30382E94DE',
  String $agent_version = $datadog_agent::params::agent_version,
  Optional[String] $agent_repo_uri = undef,
  String $release = $datadog_agent::params::apt_default_release,
  Boolean $skip_apt_key_trusting = false,
  Optional[String] $apt_keyserver = undef,
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
    $key = {
      'id' => $apt_key,
      'server' => $apt_keyserver,
    }
  } else {
    $key = {}
  }

  if ($agent_repo_uri != undef) {
    $location = $agent_repo_uri
  } else {
    $location = 'https://apt.datadoghq.com/'
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
    key      => $key,
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$datadog_agent::params::package_name],
  }

  package { $datadog_agent::params::package_name:
    ensure  => $platform_agent_version,
    require => [Apt::Source['datadog'],
                Class['apt::update']],
  }

}
