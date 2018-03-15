require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

DEBIAN_OS = %w(Ubuntu Debian)
REDHAT_OS = %w(RedHat CentOS Fedora Amazon Scientific)
ALL_OS = DEBIAN_OS + REDHAT_OS

RSpec.configure do |c|
  c.default_facts = {
    'architecture'               => 'x86_64',
    'operatingsystem'            => 'Ubuntu',
    'osfamily'                   => 'Debian',
    'operatingsystemmajrelease'  => '14',
    'operatingsystemminrelease'  => '04',
    'operatingsystemrelease'     => '14.04',
    'lsbdistrelease'             => '14.04',
    'lsbdistcodename'            => 'trusty',
    'os'                         => { 
        'name' => 'Ubuntu', 
        'family'  => 'Debian', 
        'release' => { 
            'major' => '14',
            'minor' => '04',
            'full'  => '14.04' 
        }    
    }
  }
end
