require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

DEBIAN_OS = %w(Ubuntu Debian)
REDHAT_OS = %w(RedHat CentOS Fedora Amazon Scientific)
WINDOWS_OS = %w(Windows)

if RSpec::Support::OS.windows?
  ALL_OS                     = WINDOWS_OS
  ALL_SUPPORTED_AGENTS       = { '6' => false }  # Boolean means "is agent 5". TODO: Refactor this.
  CONF_DIR6                  = 'C:/ProgramData/Datadog/conf.d'
  DD_USER                    = 'ddagentuser'
  DD_GROUP                   = 'S-1-5-32-544'
  SERVICE_NAME               = 'datadogagent'
  PACKAGE_NAME               = 'Datadog Agent'
  PERMISSIONS_FILE           = '0664'
  PERMISSIONS_PROTECTED_FILE = '0660'
else
  ALL_OS                     = DEBIAN_OS + REDHAT_OS
  ALL_SUPPORTED_AGENTS       = { '5' => true, '6' => false } # Boolean means "is agent 5". TODO: Refactor this.
  CONF_DIR6                  = '/etc/datadog-agent/conf.d'
  DD_USER                    = 'dd-agent'
  DD_GROUP                   = 'root'
  SERVICE_NAME               = 'datadog-agent'
  PACKAGE_NAME               = 'datadog-agent'
  PERMISSIONS_FILE           = '0644'
  PERMISSIONS_PROTECTED_FILE = '0600'
end


def getosfamily(operatingsystem)
  if DEBIAN_OS.include?(operatingsystem)
    return 'debian'
  elsif REDHAT_OS.include?(operatingsystem)
    return 'redhat'
  else
    return 'windows'
  end
end

def getosrelease(operatingsystem)
  if DEBIAN_OS.include?(operatingsystem)
    return '14.04'
  elsif REDHAT_OS.include?(operatingsystem)
    return '7'
  else
    return '2019'
  end
end

RSpec.configure do |c|
  c.default_facts = {
    'architecture'               => 'x86_64',
    'operatingsystem'            => (if RSpec::Support::OS.windows? then 'Windows' else 'Ubuntu' end),
    'osfamily'                   => (if RSpec::Support::OS.windows? then 'windows' else 'Debian' end),
    'operatingsystemmajrelease'  => (if RSpec::Support::OS.windows? then '2019' else '14' end),
    'operatingsystemminrelease'  => (if RSpec::Support::OS.windows? then 'SP1' else '04' end),
    'operatingsystemrelease'     => (if RSpec::Support::OS.windows? then '2019 SP1' else '14.04' end),
    'lsbdistrelease'             => (if RSpec::Support::OS.windows? then '2019 SP1' else '14.04' end),
    'lsbdistcodename'            => (if RSpec::Support::OS.windows? then '2019' else '14.04' end),
    'os'                         => {
      'name'    => (if RSpec::Support::OS.windows? then 'Windows' else 'Ubuntu' end),
      'family'  => (if RSpec::Support::OS.windows? then 'windows' else 'Debian' end),
      'release' => {
        'major' => (if RSpec::Support::OS.windows? then '2019' else '14' end),
        'minor' => (if RSpec::Support::OS.windows? then 'SP1' else '04' end),
        'full'  => (if RSpec::Support::OS.windows? then '2019 SP1' else '14.04' end)
      }
    }
  }
end
