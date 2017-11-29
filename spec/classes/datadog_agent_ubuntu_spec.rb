require 'spec_helper'

describe 'datadog_agent::ubuntu' do
  let(:facts) do
    {
      osfamily: 'debian',
      operatingsystem: 'Ubuntu'
    }
  end

  it do
    contain_file('/etc/apt/sources.list.d/datadog-beta.list')
      .with_ensure('absent')
    contain_file('/etc/apt/sources.list.d/datadog-apt.list')\
      .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+main})
  end

  # it should install the mirror
  it do
    should contain_file('/etc/apt/sources.list.d/datadog-apt.list')\
      .that_notifies('exec[datadog_apt-get_update]')
  end
  it { should contain_exec('datadog_apt-get_update') }

  # it should install the packages
  it do
    should contain_package('apt-transport-https')\
      .that_comes_before('file[/etc/apt/sources.list.d/datadog.list]')
  end
  it do
    should contain_package('datadog-agent-base')\
      .with_ensure('absent')\
      .that_comes_before('package[datadog-agent]')
  end
  it do
    should contain_package('datadog-agent')\
      .that_requires('apt::sources[datadog-apt]')\
      .that_requires('exec[datadog_apt-get_update]')
  end

  # it should be able to start the service and enable the service by default
  it do
    should contain_service('datadog-agent')\
      .that_requires('package[datadog-agent]')
  end
end

describe 'datadog_agent::ubuntu::agent6' do
  let(:facts) do
    {
      osfamily: 'debian',
      operatingsystem: 'Ubuntu'
    }
  end

  it do
    contain_file('/etc/apt/sources.list.d/datadog.list')
      .with_ensure('absent')
    contain_file('/etc/apt/sources.list.d/datadog-apt.list')\
      .with_content(%r{deb\s+https://apt.datadoghq.com/\s+beta\s+main})
  end

  it do
    should contain_file('/etc/apt/sources.list.d/datadog-apt.list')\
      .that_notifies('exec[datadog_apt-get_update]')
  end
  it { should contain_exec('datadog_apt-get_update') }

  # it should install the packages
  it do
    should contain_package('datadog-agent-base')\
      .with_ensure('absent')\
      .that_comes_before('package[datadog-agent]')
  end
  it do
    should contain_package('datadog-agent')\
      .that_requires('apt::sources[datadog-apt]')\
      .that_requires('exec[datadog_apt-get_update]')
  end

  # it should be able to start the service and enable the service by default
  it do
    should contain_service('datadog-agent')\
      .that_requires('package[datadog-agent]')
  end
end
