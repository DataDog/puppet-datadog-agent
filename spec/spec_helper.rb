require 'puppetlabs_spec_helper/module_spec_helper'

DEBIAN_OS = ['Ubuntu', 'Debian'].freeze
REDHAT_OS = ['RedHat', 'CentOS', 'Fedora', 'Amazon', 'Scientific', 'OracleLinux'].freeze
WINDOWS_OS = ['Windows'].freeze

if RSpec::Support::OS.windows?
  ALL_OS                     = WINDOWS_OS
  ALL_SUPPORTED_AGENTS       = [6, 7].freeze
  CONF_DIR = 'C:/ProgramData/Datadog/conf.d'.freeze
  DD_USER                    = 'ddagentuser'.freeze
  DD_GROUP                   = 'S-1-5-32-544'.freeze
  SERVICE_NAME               = 'datadogagent'.freeze
  PACKAGE_NAME               = 'Datadog Agent'.freeze
  PERMISSIONS_FILE           = '0664'.freeze
  PERMISSIONS_PROTECTED_FILE = '0660'.freeze
else
  ALL_OS                     = DEBIAN_OS + REDHAT_OS
  ALL_SUPPORTED_AGENTS       = [5, 6, 7].freeze
  CONF_DIR = '/etc/datadog-agent/conf.d'.freeze
  DD_USER                    = 'dd-agent'.freeze
  DD_GROUP                   = 'dd-agent'.freeze
  SERVICE_NAME               = 'datadog-agent'.freeze
  PACKAGE_NAME               = 'datadog-agent'.freeze
  PERMISSIONS_FILE           = '0644'.freeze
  PERMISSIONS_PROTECTED_FILE = '0600'.freeze
end

def getosfamily(operatingsystem)
  if DEBIAN_OS.include?(operatingsystem)
    'debian'
  elsif REDHAT_OS.include?(operatingsystem)
    'redhat'
  else
    'windows'
  end
end

def getosrelease(operatingsystem)
  if DEBIAN_OS.include?(operatingsystem)
    '14.04'
  elsif REDHAT_OS.include?(operatingsystem)
    '7'
  else
    '2019'
  end
end

RSpec.configure do |c|
  c.default_facts = {
    'architecture'               => 'x86_64',
    'operatingsystem'            => (RSpec::Support::OS.windows? ? 'Windows' : 'Ubuntu'),
    'osfamily'                   => (RSpec::Support::OS.windows? ? 'windows' : 'Debian'),
    'operatingsystemmajrelease'  => (RSpec::Support::OS.windows? ? '2019' : '14'),
    'operatingsystemminrelease'  => (RSpec::Support::OS.windows? ? 'SP1' : '04'),
    'operatingsystemrelease'     => (RSpec::Support::OS.windows? ? '2019 SP1' : '14.04'),
    'lsbdistrelease'             => (RSpec::Support::OS.windows? ? '2019 SP1' : '14.04'),
    'lsbdistcodename'            => (RSpec::Support::OS.windows? ? '2019' : '14.04'),
    'os'                         => {
      'name'    => (RSpec::Support::OS.windows? ? 'Windows' : 'Ubuntu'),
      'family'  => (RSpec::Support::OS.windows? ? 'windows' : 'Debian'),
      'release' => {
        'major' => (RSpec::Support::OS.windows? ? '2019' : '14'),
        'minor' => (RSpec::Support::OS.windows? ? 'SP1' : '04'),
        'full'  => (RSpec::Support::OS.windows? ? '2019 SP1' : '14.04'),
      },
    },
  }
end

# Get parameters from catalogue.
def get_from_catalogue(type, name, parameter)
  catalogue.resource(type, name).send(:parameters)[parameter.to_sym]
end
