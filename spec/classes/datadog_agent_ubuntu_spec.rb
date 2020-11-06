require 'spec_helper'

describe 'datadog_agent::ubuntu' do
  context 'agent 5' do
    if RSpec::Support::OS.windows?
      return
    end
    let(:params) do
      {
        agent_major_version: 5,
      }
    end
    let(:facts) do
      {
        osfamily: 'debian',
        operatingsystem: 'Ubuntu',
      }
    end

    it do
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog5.list')
        .with_ensure('absent')
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog6.list')
        .with_ensure('absent')
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
        .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+main})
    end

    # it should install the mirror
    it { is_expected.not_to contain_apt__key('935F5A436A5A6E8788F0765B226AE980C7A7DA52') }
    it do
      is_expected.to contain_apt__key('A2923DFF56EDA6E76E55E492D3A80E30382E94DE')
      is_expected.to contain_apt__key('D75CEA17048B9ACBF186794B32637D44F14F620E')
    end

    context 'overriding keyserver' do
      let(:params) do
        {
          apt_keyserver: 'hkp://pool.sks-keyservers.net:80',
        }
      end

      it do
        is_expected.to contain_apt__key('A2923DFF56EDA6E76E55E492D3A80E30382E94DE')\
          .with_server('hkp://pool.sks-keyservers.net:80')
        is_expected.to contain_apt__key('D75CEA17048B9ACBF186794B32637D44F14F620E')\
          .with_server('hkp://pool.sks-keyservers.net:80')
      end
    end

    it do
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
        .that_notifies('exec[apt_update]')
    end
    it { is_expected.to contain_exec('apt_update') }

    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent-base')\
        .with_ensure('absent')\
        .that_comes_before('package[datadog-agent]')
    end
    it do
      is_expected.to contain_package('datadog-agent')\
        .that_requires('file[/etc/apt/sources.list.d/datadog.list]')\
        .that_requires('exec[apt_update]')
    end
  end

  context 'agent 6' do
    let(:params) do
      {
        agent_major_version: 6,
      }
    end

    let(:facts) do
      {
        osfamily: 'debian',
        operatingsystem: 'Ubuntu',
      }
    end

    it do
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog5.list')
        .with_ensure('absent')
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog6.list')
        .with_ensure('absent')
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
        .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+6})
    end

    # it should install the mirror
    it { is_expected.not_to contain_apt__key('935F5A436A5A6E8788F0765B226AE980C7A7DA52') }
    it do
      is_expected.to contain_apt__key('A2923DFF56EDA6E76E55E492D3A80E30382E94DE')
      is_expected.to contain_apt__key('D75CEA17048B9ACBF186794B32637D44F14F620E')
    end

    it do
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog6.list')\
        .that_notifies('exec[apt_update]')
    end
    it { is_expected.to contain_exec('apt_update') }

    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent-base')\
        .with_ensure('absent')\
        .that_comes_before('package[datadog-agent]')
    end
    it do
      is_expected.to contain_package('datadog-agent')\
        .that_requires('file[/etc/apt/sources.list.d/datadog6.list]')\
        .that_requires('exec[apt_update]')
    end
  end

  context 'agent 7' do
    let(:params) do
      {
        agent_major_version: 7,
      }
    end

    let(:facts) do
      {
        osfamily: 'debian',
        operatingsystem: 'Ubuntu',
      }
    end

    it do
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog5.list')
        .with_ensure('absent')
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog6.list')
        .with_ensure('absent')
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
        .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+7})
    end

    # it should install the mirror
    it { is_expected.not_to contain_apt__key('935F5A436A5A6E8788F0765B226AE980C7A7DA52') }
    it { is_expected.to contain_apt__key('A2923DFF56EDA6E76E55E492D3A80E30382E94DE') }

    it do
      is_expected.to contain_file('/etc/apt/sources.list.d/datadog6.list')\
        .that_notifies('exec[apt_update]')
    end
    it { is_expected.to contain_exec('apt_update') }

    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent-base')\
        .with_ensure('absent')\
        .that_comes_before('package[datadog-agent]')
    end
    it do
      is_expected.to contain_package('datadog-agent')\
        .that_requires('file[/etc/apt/sources.list.d/datadog6.list]')\
        .that_requires('exec[apt_update]')
    end
  end
end
