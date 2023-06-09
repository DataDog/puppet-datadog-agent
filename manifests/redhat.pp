# Class: datadog_agent::redhat
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#

class datadog_agent::redhat(
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  Optional[String] $agent_repo_uri = undef,
  Boolean $manage_repo = true,
  String $agent_version = $datadog_agent::params::agent_version,
  String $agent_flavor = $datadog_agent::params::package_name,
  Optional[Boolean] $rpm_repo_gpgcheck = undef,
) inherits datadog_agent::params {

  if $manage_repo {

    $keys = [
        'https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public',
        'https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
        'https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public',
        'https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public',
    ]

    if ($rpm_repo_gpgcheck != undef) {
      $repo_gpgcheck = $rpm_repo_gpgcheck
    } else {
      if ($agent_repo_uri == undef) and ($agent_major_version > 5) {
        case $::operatingsystem {
          'RedHat', 'CentOS', 'OracleLinux': {
            # disable repo_gpgcheck on 8.1 because of https://bugzilla.redhat.com/show_bug.cgi?id=1792506
            if $::operatingsystemrelease =~ /^8.1/ {
              $repo_gpgcheck = false
            } else {
              $repo_gpgcheck = true
            }
          }
          default: {
            $repo_gpgcheck = true
          }
        }
      } else {
        $repo_gpgcheck = false
      }

    }

    case $agent_major_version {
      5 : {
        $defaulturl = "https://yum.datadoghq.com/rpm/${::architecture}/"
        $gpgkeys = $keys
      }
      6 : {
        $defaulturl = "https://yum.datadoghq.com/stable/6/${::architecture}/"
        $gpgkeys = $keys
      }
      7 : {
        $defaulturl = "https://yum.datadoghq.com/stable/7/${::architecture}/"
        $gpgkeys = $keys
      }
      default: { fail('invalid agent_major_version') }
    }

    if ($agent_repo_uri != undef) {
      $baseurl = $agent_repo_uri
    } else {
      $baseurl = $defaulturl
    }

    exec { 'ensure key 4172A230 is removed from the RPM database':
      command => '/bin/rpm --erase gpg-pubkey-4172a230-55dd14f6',
      onlyif  => '/bin/rpm -q gpg-pubkey-4172a230-55dd14f6',
    }

    yumrepo { 'datadog-beta':
      ensure => absent,
    }

    yumrepo {'datadog5':
      ensure   => absent,
    }

    yumrepo {'datadog6':
      ensure   => absent,
    }

    yumrepo {'datadog':
      enabled       => 1,
      gpgcheck      => 1,
      gpgkey        => join($gpgkeys, "\n       "),
      repo_gpgcheck => $repo_gpgcheck,
      descr         => 'Datadog, Inc.',
      baseurl       => $baseurl,
    }

    package { $agent_flavor:
      ensure  => $agent_version,
      require => Yumrepo['datadog'],
    }
  } else {
    package { $agent_flavor:
      ensure  => $agent_version,
    }
  }
}
