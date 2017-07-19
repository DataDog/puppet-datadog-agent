require 'spec_helper'

describe 'datadog_agent::ubuntu' do
  let(:facts) do
    {
      osfamily: 'debian',
      operatingsystem: 'Ubuntu'
    }
  end

  it do
    contain_file('/etc/apt/sources.list.d/datadog.list')\
      .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+main})
  end

  # it should install the mirror
  it { should contain_datadog_agent__ubuntu__install_key('935F5A436A5A6E8788F0765B226AE980C7A7DA52') }
  it { should contain_datadog_agent__ubuntu__install_key('A2923DFF56EDA6E76E55E492D3A80E30382E94DE') }
  it do
    should contain_file('/etc/apt/sources.list.d/datadog.list')\
      .that_notifies('Exec[datadog_apt-get_update]')
  end
  it { should contain_exec('datadog_apt-get_update') }

  # it should install the packages
  it do
    should contain_package('apt-transport-https')\
      .that_comes_before('File[/etc/apt/sources.list.d/datadog.list]')
  end
  it do
    should contain_package('datadog-agent-base')\
      .with_ensure('absent')\
      .that_comes_before('Package[datadog-agent]')
  end
  it do
    should contain_package('datadog-agent')\
      .that_requires('File[/etc/apt/sources.list.d/datadog.list]')\
      .that_requires('Exec[datadog_apt-get_update]')
  end

  # it should be able to start the service and enable the service by default
  it do
    should contain_service('datadog-agent')\
      .that_requires('Package[datadog-agent]')
  end
end
