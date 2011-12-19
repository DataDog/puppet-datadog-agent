# Class: datadog::reports
#
# This class configures the puppetmaster for reporting back to 
# the datadog service.
#
# Parameters:
#   $api_key:
#       Your DataDog API Key. Please replace with your key value
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog::reports(
  $api_key,
  $puppetmaster_user
) {

  file { "/etc/dd-agent/datadog.yaml":
    ensure   => file,
    content  => template("datadog/datadog.yaml.erb"),
    owner    => $puppetmaster_user,
    group    => "root",
    mode     => 0640,
    notify   => Service["datadog-agent"],
    require  => File["/etc/dd-agent"],
  }

  package{'dogapi':
    ensure    => 'installed',
    provider  => 'gem',
  }

}
