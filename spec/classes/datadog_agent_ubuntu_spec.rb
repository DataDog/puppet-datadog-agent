require 'spec_helper'

shared_examples 'old debianoid' do
  it do
    is_expected.to contain_file('/usr/share/keyrings/datadog-archive-keyring.gpg')
    is_expected.to contain_file('/etc/apt/trusted.gpg.d/datadog-archive-keyring.gpg')
    is_expected.to contain_exec('ensure key DATADOG_APT_KEY_CURRENT.public is imported in APT keyring')
    is_expected.to contain_exec('ensure key 5F1E256061D813B125E156E8E6266D4AC0962C7D is imported in APT keyring')
    is_expected.to contain_exec('ensure key D75CEA17048B9ACBF186794B32637D44F14F620E is imported in APT keyring')
    is_expected.to contain_exec('ensure key A2923DFF56EDA6E76E55E492D3A80E30382E94DE is imported in APT keyring')
  end
end

shared_examples 'new debianoid' do
  it do
    is_expected.to contain_file('/usr/share/keyrings/datadog-archive-keyring.gpg')
    is_expected.not_to contain_file('/etc/apt/trusted.gpg.d/datadog-archive-keyring.gpg')
    is_expected.to contain_exec('ensure key DATADOG_APT_KEY_CURRENT.public is imported in APT keyring')
    is_expected.to contain_exec('ensure key 5F1E256061D813B125E156E8E6266D4AC0962C7D is imported in APT keyring')
    is_expected.to contain_exec('ensure key D75CEA17048B9ACBF186794B32637D44F14F620E is imported in APT keyring')
    is_expected.to contain_exec('ensure key A2923DFF56EDA6E76E55E492D3A80E30382E94DE is imported in APT keyring')
  end
end

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
        .with_content(%r{deb\s+\[signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg\]\s+https://apt.datadoghq.com/\s+stable\s+main})
    end

    # it should install the mirror
    it { is_expected.not_to contain_apt__key('935F5A436A5A6E8788F0765B226AE980C7A7DA52') }

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
        .with_content(%r{deb\s+\[signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg\]\s+https://apt.datadoghq.com/\s+stable\s+6})
    end

    # it should install the mirror
    it { is_expected.not_to contain_apt__key('935F5A436A5A6E8788F0765B226AE980C7A7DA52') }

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
        .with_content(%r{deb\s+\[signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg\]\s+https://apt.datadoghq.com/\s+stable\s+7})
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

  context 'ubuntu < 16' do
    let(:params) do
      {
        agent_major_version: 7,
      }
    end

    let(:facts) do
      {
        osfamily: 'debian',
        operatingsystem: 'Ubuntu',
        operatingsystemrelease: '14.04',
      }
    end

    include_examples 'old debianoid'
  end

  context 'ubuntu >= 16' do
    let(:params) do
      {
        agent_major_version: 7,
      }
    end

    let(:facts) do
      {
        osfamily: 'debian',
        operatingsystem: 'Ubuntu',
        operatingsystemrelease: '16.04',
      }
    end

    include_examples 'new debianoid'
  end

  context 'debian < 9' do
    let(:params) do
      {
        agent_major_version: 7,
      }
    end

    let(:facts) do
      {
        osfamily: 'debian',
        operatingsystem: 'Debian',
        operatingsystemrelease: '8.0',
      }
    end

    include_examples 'old debianoid'
  end

  context 'debian >= 9' do
    let(:params) do
      {
        agent_major_version: 7,
      }
    end

    let(:facts) do
      {
        osfamily: 'debian',
        operatingsystem: 'Debian',
        operatingsystemrelease: '9.0',
      }
    end

    include_examples 'new debianoid'
  end
end
