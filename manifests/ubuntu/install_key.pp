# Resource type: datadog_agent::ubuntu::install_key
#
# This resource type install repository keys in Ubuntu
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#
#
define datadog_agent::ubuntu::install_key() {
  apt::key { $name:
    id     => $name,
    server => 'hkp://keyserver.ubuntu.com:80',
    retries => '4',
  }
}
