# Class: datadog_agent::redhat
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#
# Parameters:
#   $baseurl:
#       Baseurl for the datadog yum repo
#       Defaults to http://yum.datadoghq.com/rpm/${::architecture}/
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#
class datadog_agent::redhat(
  $baseurl = "https://yum.datadoghq.com/rpm/${::architecture}/",
  $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
  $manage_repo = true,
  $agent_version = 'latest'
) {

  validate_bool($manage_repo)
  if $manage_repo {
    $public_key_local = '/etc/pki/rpm-gpg/DATADOG_RPM_KEY.public'

    validate_string($baseurl)

    remote_file { 'DATADOG_RPM_KEY.public':
        owner  => root,
        group  => root,
        mode   => '600',
        path   => $public_key_local,
        source => $gpgkey
    }

    exec { 'install-gpg-key':
        command => "/bin/rpm --import ${public_key_local}",
        onlyif  => "/usr/bin/gpg --quiet --with-fingerprint -n ${public_key_local} | grep \'A4C0 B90D 7443 CF6E 4E8A  A341 F106 8E14 E094 22B3\'",
        unless  => '/bin/rpm -q gpg-pubkey-e09422b3',
        require => Remote_file['DATADOG_RPM_KEY.public'],
    }

    yumrepo {'datadog':
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public',
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl,
      require  => Exec['install-gpg-key'],
    }

    Package { require => Yumrepo['datadog']}
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package['datadog-agent'],
  }

  package { 'datadog-agent':
    ensure  => $agent_version,
  }

  service { 'datadog-agent':
    ensure    => $::datadog_agent::service_ensure,
    enable    => $::datadog_agent::service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    provider  => 'redhat',
    require   => Package['datadog-agent'],
  }

}
