require 'spec_helper'

describe 'datadog_agent::ubuntu::agent5' do

  if RSpec::Support::OS.windows?
    return
  end

  let(:facts) do
    {
      osfamily: 'debian',
      operatingsystem: 'Ubuntu'
    }
  end

  it do
    contain_file('/etc/apt/sources.list.d/datadog6.list')
      .with_ensure('absent')
    contain_file('/etc/apt/sources.list.d/datadog.list')\
      .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+main})
  end

  # it should install the mirror
  it { should_not contain_apt__key('Add key: 935F5A436A5A6E8788F0765B226AE980C7A7DA52 from Apt::Source datadog') }
  it do
    should contain_apt__key('Add key: A2923DFF56EDA6E76E55E492D3A80E30382E94DE from Apt::Source datadog')
  end
  context 'overriding keyserver' do
    let(:params) {{
      apt_keyserver: 'hkp://pool.sks-keyservers.net:80',
    }}
    it do
      should contain_apt__key('Add key: A2923DFF56EDA6E76E55E492D3A80E30382E94DE from Apt::Source datadog')\
        .with_server('hkp://pool.sks-keyservers.net:80')
    end
  end

  it do
    should contain_file('/etc/apt/sources.list.d/datadog.list')\
      .that_notifies('exec[apt_update]')
  end
  it { should contain_exec('apt_update') }

  # it should install the packages
  it do
    should contain_package('datadog-agent-base')\
      .with_ensure('absent')\
      .that_comes_before('package[datadog-agent]')
  end
  it do
    should contain_package('datadog-agent')\
      .that_requires('file[/etc/apt/sources.list.d/datadog.list]')\
      .that_requires('exec[apt_update]')
  end

  # it should be able to start the service and enable the service by default
  it do
    should contain_service('datadog-agent')\
      .that_requires('package[datadog-agent]')
  end

  context 'overriding provider' do
    let(:params) {{
      service_provider: 'upstart',
    }}
    it do
      should contain_service('datadog-agent')\
        .that_requires('package[datadog-agent]')
    end
    it do
      should contain_service('datadog-agent').with(
        'provider' => 'upstart',
        'ensure' => 'running',
      )
    end
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
    contain_file('/etc/apt/sources.list.d/datadog6.list')\
      .with_content(%r{deb\s+https://apt.datadoghq.com/\s+beta\s+main})
  end

  # it should install the mirror
  it { should_not contain_apt__key('Add key: 935F5A436A5A6E8788F0765B226AE980C7A7DA52 from Apt::Source datadog6') }
  it { should contain_apt__key('Add key: A2923DFF56EDA6E76E55E492D3A80E30382E94DE from Apt::Source datadog6') }

  it do
    should contain_file('/etc/apt/sources.list.d/datadog6.list')\
      .that_notifies('exec[apt_update]')
  end
  it { should contain_exec('apt_update') }

  # it should install the packages
  it do
    should contain_package('datadog-agent-base')\
      .with_ensure('absent')\
      .that_comes_before('package[datadog-agent]')
  end
  it do
    should contain_package('datadog-agent')\
      .that_requires('file[/etc/apt/sources.list.d/datadog6.list]')\
      .that_requires('exec[apt_update]')
  end

  # it should be able to start the service and enable the service by default
  it do
    should contain_service('datadog-agent')\
      .that_requires('package[datadog-agent]')
  end

  context 'overriding provider' do
    let(:params) {{
      service_provider: 'upstart',
    }}
    it do
      should contain_service('datadog-agent')\
        .that_requires('package[datadog-agent]')
    end
    it do
      should contain_service('datadog-agent').with(
        'provider' => 'upstart',
        'ensure' => 'running',
      )
    end
  end
end
