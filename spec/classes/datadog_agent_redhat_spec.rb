require 'spec_helper'

describe 'datadog_agent::redhat' do
  context 'agent 5' do
    if RSpec::Support::OS.windows?
      return
    end

    let(:facts) do
      {
        osfamily: 'redhat',
        operatingsystem: 'Fedora',
        architecture: 'x86_64',
      }
    end

    # it should install the mirror
    context 'with manage_repo => true' do
      let(:params) do
        {
          manage_repo: true,
          agent_major_version: 5,
        }
      end

      it do
        is_expected.to contain_yumrepo('datadog')
          .with_enabled(1)\
          .with_gpgcheck(1)\
          .with_gpgkey('https://yum.datadoghq.com/DATADOG_RPM_KEY.public')\
          .with_baseurl('https://yum.datadoghq.com/rpm/x86_64/')
      end
    end
    context 'with manage_repo => false' do
      let(:params) do
        {
          manage_repo: false, agent_major_version: 5
        }
      end

      it do
        is_expected.not_to contain_yumrepo('datadog')
        is_expected.not_to contain_yumrepo('datadog5')
        is_expected.not_to contain_yumrepo('datadog6')
      end
    end
    context 'overriding provider' do
      let(:params) do
        {
          service_provider: 'upstart',
          agent_major_version: 5,
        }
      end

      it do
        is_expected.to contain_service('datadog-agent')\
          .that_requires('package[datadog-agent]')
      end
      it do
        is_expected.to contain_service('datadog-agent').with(
          'provider' => 'upstart',
          'ensure' => 'running',
        )
      end
    end

    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent')\
        .with_ensure('latest')
    end

    # it should be able to start the service and enable the service by default
    it do
      is_expected.to contain_service('datadog-agent')\
        .that_requires('Package[datadog-agent]')
    end
  end

  context 'agent 6' do
    let(:facts) do
      {
        osfamily: 'redhat',
        operatingsystem: 'Fedora',
        architecture: 'x86_64',
      }
    end

    # it should install the mirror
    context 'with manage_repo => true' do
      let(:params) do
        {
          manage_repo: true, agent_major_version: 6
        }
      end

      it do
        is_expected.to contain_yumrepo('datadog')
          .with_enabled(1)\
          .with_gpgcheck(1)\
          .with_gpgkey('https://yum.datadoghq.com/DATADOG_RPM_KEY.public')\
          .with_baseurl('https://yum.datadoghq.com/stable/6/x86_64/')
      end
    end
    context 'with manage_repo => false' do
      let(:params) do
        {
          manage_repo: false, agent_major_version: 6
        }
      end

      it do
        is_expected.not_to contain_yumrepo('datadog')
        is_expected.not_to contain_yumrepo('datadog5')
        is_expected.not_to contain_yumrepo('datadog6')
      end
    end
    context 'overriding provider' do
      let(:params) do
        {
          service_provider: 'upstart',
          agent_major_version: 6,
        }
      end

      it do
        is_expected.to contain_service('datadog-agent')\
          .that_requires('package[datadog-agent]')
      end
      it do
        is_expected.to contain_service('datadog-agent').with(
          'provider' => 'upstart',
          'ensure' => 'running',
        )
      end
    end

    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent')\
        .with_ensure('latest')
    end

    # it should be able to start the service and enable the service by default
    it do
      is_expected.to contain_service('datadog-agent')\
        .that_requires('Package[datadog-agent]')
    end
  end

  context 'agent 7' do
    let(:facts) do
      {
        osfamily: 'redhat',
        operatingsystem: 'Fedora',
        architecture: 'x86_64',
      }
    end

    # it should install the mirror
    context 'with manage_repo => true' do
      let(:params) do
        {
          manage_repo: true, agent_major_version: 7
        }
      end

      it do
        is_expected.to contain_yumrepo('datadog')
          .with_enabled(1)\
          .with_gpgcheck(1)\
          .with_gpgkey('https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public')\
          .with_baseurl('https://yum.datadoghq.com/stable/7/x86_64/')
      end
    end
    context 'with manage_repo => false' do
      let(:params) do
        {
          manage_repo: false,
          agent_major_version: 7,
        }
      end

      it do
        is_expected.not_to contain_yumrepo('datadog')
        is_expected.not_to contain_yumrepo('datadog5')
        is_expected.not_to contain_yumrepo('datadog6')
      end
    end
    context 'overriding provider' do
      let(:params) do
        {
          service_provider: 'upstart',
          agent_major_version: 7,
        }
      end

      it do
        is_expected.to contain_service('datadog-agent')\
          .that_requires('package[datadog-agent]')
      end
      it do
        is_expected.to contain_service('datadog-agent').with(
          'provider' => 'upstart',
          'ensure' => 'running',
        )
      end
    end

    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent')\
        .with_ensure('latest')
    end

    # it should be able to start the service and enable the service by default
    it do
      is_expected.to contain_service('datadog-agent')\
        .that_requires('Package[datadog-agent]')
    end
  end
end
