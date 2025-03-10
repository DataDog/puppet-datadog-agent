# frozen_string_literal: true

RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

require 'spec_helper_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_local.rb'))

include RspecPuppetFacts

DEBIAN_OS = ['Ubuntu', 'Debian'].freeze
REDHAT_OS = ['RedHat', 'CentOS', 'Fedora', 'Amazon', 'Scientific', 'OracleLinux', 'AlmaLinux', 'Rocky'].freeze
WINDOWS_OS = ['Windows'].freeze

if RSpec::Support::OS.windows?
  ALL_OS                     = WINDOWS_OS
  ALL_SUPPORTED_AGENTS       = [6, 7].freeze
  CONF_DIR = 'C:/ProgramData/Datadog/conf.d'
  DD_USER                    = 'ddagentuser'
  DD_GROUP                   = 'S-1-5-32-544'
  SERVICE_NAME               = 'datadogagent'
  PACKAGE_NAME               = 'Datadog Agent'
  PERMISSIONS_FILE           = '0664'
  PERMISSIONS_PROTECTED_FILE = '0660'
else
  ALL_OS                     = DEBIAN_OS + REDHAT_OS
  ALL_SUPPORTED_AGENTS       = [6, 7].freeze
  CONF_DIR = '/etc/datadog-agent/conf.d'
  DD_USER                    = 'dd-agent'
  DD_GROUP                   = 'dd-agent'
  SERVICE_NAME               = 'datadog-agent'
  PACKAGE_NAME               = 'datadog-agent'
  PERMISSIONS_FILE           = '0644'
  PERMISSIONS_PROTECTED_FILE = '0600'
end

def min_puppet_version(version)
  Gem.loaded_specs['puppet'].version > Gem::Version.new(version)
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

def getosmajor(operatingsystem)
  if DEBIAN_OS.include?(operatingsystem)
    '14'
  elsif REDHAT_OS.include?(operatingsystem)
    '7'
  else
    '2019'
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

def getoscodename(operatingsystem)
  if DEBIAN_OS.include?(operatingsystem)
    'trusty'
  elsif REDHAT_OS.include?(operatingsystem)
    'maipo'
  else
    'seattle'
  end
end

# Get parameters from catalogue.
def get_from_catalogue(type, name, parameter)
  catalogue.resource(type, name).send(:parameters)[parameter.to_sym]
end

default_facts = {
  puppetversion:              Puppet.version,
  facterversion:              Facter.version,
  architecture:               'x86_64',
  operatingsystem:            (RSpec::Support::OS.windows? ? 'Windows' : 'Ubuntu'),
  osfamily:                   (RSpec::Support::OS.windows? ? 'windows' : 'Debian'),
  operatingsystemmajrelease:  (RSpec::Support::OS.windows? ? '2019' : '14'),
  operatingsystemminrelease:  (RSpec::Support::OS.windows? ? 'SP1' : '04'),
  operatingsystemrelease:     (RSpec::Support::OS.windows? ? '2019 SP1' : '14.04'),
  lsbdistrelease:             (RSpec::Support::OS.windows? ? '2019 SP1' : '14.04'),
  lsbdistcodename:            (RSpec::Support::OS.windows? ? '2019' : '14.04'),
  os:                         {
    architecture: 'x86_64',
    name:         (RSpec::Support::OS.windows? ? 'Windows' : 'Ubuntu'),
    family:       (RSpec::Support::OS.windows? ? 'windows' : 'Debian'),
    release:      {
      major:        (RSpec::Support::OS.windows? ? '2019' : '14'),
      minor:        (RSpec::Support::OS.windows? ? 'SP1' : '04'),
      full:         (RSpec::Support::OS.windows? ? '2019 SP1' : '14.04'),
    },
    'distro' => {
      'codename' => (RSpec::Support::OS.windows? ? 'seattle' : 'focal'),
    },
  }
}

default_fact_files = [
  File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml')),
  File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml')),
]

default_fact_files.each do |f|
  next unless File.exist?(f) && File.readable?(f) && File.size?(f)

  begin
    require 'deep_merge'
    default_facts.deep_merge!(YAML.safe_load(File.read(f), permitted_classes: [], permitted_symbols: [], aliases: true))
  rescue StandardError => e
    RSpec.configuration.reporter.message "WARNING: Unable to load #{f}: #{e}"
  end
end

# read default_facts and merge them over what is provided by facterdb
default_facts.each do |fact, value|
  add_custom_fact fact, value, merge_facts: true
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.before :each do
    # set to strictest setting for testing
    # by default Puppet runs at warning level
    Puppet.settings[:strict] = :warning
    Puppet.settings[:strict_variables] = true
  end
  c.filter_run_excluding(bolt: true) unless ENV['GEM_BOLT']
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(0)
  end

  # Filter backtrace noise
  backtrace_exclusion_patterns = [
    %r{spec_helper},
    %r{gems},
  ]

  if c.respond_to?(:backtrace_exclusion_patterns)
    c.backtrace_exclusion_patterns = backtrace_exclusion_patterns
  elsif c.respond_to?(:backtrace_clean_patterns)
    c.backtrace_clean_patterns = backtrace_exclusion_patterns
  end
end

# Ensures that a module is defined
# @param module_name Name of the module
def ensure_module_defined(module_name)
  module_name.split('::').reduce(Object) do |last_module, next_module|
    last_module.const_set(next_module, Module.new) unless last_module.const_defined?(next_module, false)
    last_module.const_get(next_module, false)
  end
end

# 'spec_overrides' from sync.yml will appear below this line
