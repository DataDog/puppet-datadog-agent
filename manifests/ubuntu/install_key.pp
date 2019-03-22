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
define datadog_agent::ubuntu::install_key($server) {
  apt::key { $name:
    id     => $name,
    server => $server,
  }
}
