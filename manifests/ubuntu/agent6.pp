# Class: datadog_agent::ubuntu::agent6
#
# This class contains the DataDog agent installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu::agent6(
  $apt_key = 'A2923DFF56EDA6E76E55E492D3A80E30382E94DE',
  $agent_version = 'latest',
  $other_keys = ['935F5A436A5A6E8788F0765B226AE980C7A7DA52'],
  $location = 'https://apt.datadoghq.com',
  $release = 'beta',
  $repos = 'main',
) {
  class { 'datadog_agent::ubuntu':
    apt_key       => $apt_key,
    agent_version => $agent_version,
    other_keys    => $other_keys,
    location      => $location,
    release       => $release,
    repos         => $repos,
  }
}
