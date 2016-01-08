require 'spec_helper'

describe 'datadog_agent::ubuntu' do
  let(:facts) {
    {
      osfamily: 'Debian',
      operatingsystem: 'Ubuntu',
      lsbdistid: 'Ubuntu',
    }
  }

  let(:version) { 'latest' }

  # it should install the mirror
  
  it { should contain_apt__source('datadog').with(
    :ensure      => 'present',
    :location    => 'http://apt.datadoghq.com',
    :release     => 'stable',
    :repos       => 'main',
    :include     => { 'src' => false },
    :key         => { 'id' => 'C7A7DA52', 'server' => 'pgp.mit.edu' },
    :before      => 'Package[datadog-agent]',
  ) }

  # it should install the packages
  it do
    should contain_package('apt-transport-https').with_ensure('latest')
  end
  it do
    should contain_package('datadog-agent-base')\
      .with_ensure('absent')\
      .that_comes_before('Package[datadog-agent]')
  end
  it do
    should contain_package('datadog-agent')\
      .with_ensure("#{version}")
  end

  # it should be able to start the service and enable the service by default
  it do
    should contain_service('datadog-agent')\
      .that_requires('Package[datadog-agent]')
  end
end
