require 'spec_helper'

describe 'datadog_agent::ubuntu' do
  let(:facts) do
    {
      osfamily: 'debian',
      operatingsystem: 'Ubuntu'
    }
  end

  context 'with manage_repo => true' do
    let(:params) { {:manage_repo => true} }
    it do
      contain_file('/etc/apt/sources.list.d/datadog.list')\
        .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+main})
    end

    # it should install the mirror
    it { should contain_datadog_agent__ubuntu__install_key('C7A7DA52') }
    it { should contain_datadog_agent__ubuntu__install_key('382E94DE') }
    it do
      should contain_file('/etc/apt/sources.list.d/datadog.list')\
        .that_notifies('Exec[datadog_apt-get_update]')
   end
    it { should contain_exec('datadog_apt-get_update') }
  end

  context 'with manage_repo => false' do
    let(:params) { {:manage_repo => false} }
    it do
      should_not contain_file('/etc/apt/sources.list.d/datadog.list')
    end
  end

  # it should install the packages
  it do
    should contain_package('apt-transport-https')
  end
  it do
    should contain_package('datadog-agent-base')\
      .with_ensure('absent')\
      .that_comes_before('Package[datadog-agent]')
  end
  it do
    should contain_package('datadog-agent')\
      .that_requires('Exec[datadog_apt-get_update]')
  end

  # it should be able to start the service and enable the service by default
  it do
    should contain_service('datadog-agent')\
      .that_requires('Package[datadog-agent]')
  end
end
