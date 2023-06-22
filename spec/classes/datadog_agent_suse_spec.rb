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

  context 'suse >= 15' do
    let(:facts) do
      {
        operatingsystemmajrelease: '15',
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public')\
          .with_baseurl('https://yum.datadoghq.com/suse/stable/6/x86_64')
        # .with_repo_gpgcheck(true)
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public')\
          .with_baseurl('https://yum.datadoghq.com/suse/stable/7/x86_64')
        # .with_repo_gpgcheck(true)
      end
    end
  end

  context 'suse < 15' do
    let(:facts) do
      {
        operatingsystemmajrelease: '14',
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public')\
          .with_baseurl('https://yum.datadoghq.com/suse/stable/6/x86_64')
        # .with_repo_gpgcheck(true)
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public')\
          .with_baseurl('https://yum.datadoghq.com/suse/stable/7/x86_64')
        # .with_repo_gpgcheck(true)
      end
    end
  end

  # it should install the packages
  it do
    is_expected.to contain_package('datadog-agent')\
      .with_ensure('latest')
  end
end
