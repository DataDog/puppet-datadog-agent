require 'spec_helper'

describe 'datadog_agent::suse' do
  if RSpec::Support::OS.windows?
    return
  end

  let(:facts) do
    {
      operatingsystem: 'OpenSuSE',
      architecture: 'x86_64',
    }
  end

  context 'agent 6' do
    let(:params) do
      {
        agent_major_version: 6,
      }
    end

    it do
      is_expected.to contain_zypprepo('datadog')
        .with_enabled(1)\
        .with_gpgcheck(1)\
        .with_gpgkey('https://yum.datadoghq.com/DATADOG_RPM_KEY.public	https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public	https://yum.datadoghq.com/DATADOG_RPM_KEY_20200908.public')\
        .with_baseurl('https://yum.datadoghq.com/suse/stable/6/x86_64')
    end
  end

  context 'agent 7' do
    let(:params) do
      {
        agent_major_version: 7,
      }
    end

    it do
      is_expected.to contain_zypprepo('datadog')
        .with_enabled(1)\
        .with_gpgcheck(1)\
        .with_gpgkey('https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public	https://yum.datadoghq.com/DATADOG_RPM_KEY_20200908.public')\
        .with_baseurl('https://yum.datadoghq.com/suse/stable/7/x86_64')
    end
  end

  # it should install the packages
  it do
    is_expected.to contain_package('datadog-agent')\
      .with_ensure('latest')
  end
end
