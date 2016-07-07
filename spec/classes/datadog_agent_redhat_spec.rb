require 'spec_helper'

describe 'datadog_agent::redhat' do
  let(:facts) do
    {
      osfamily: 'redhat',
      operatingsystem: 'Fedora',
      architecture: 'x86_64'
    }
  end

  # it should install the mirror
  context 'with manage_repo => true' do
    let(:params){ {:manage_repo => true} }
    it do
      should contain_yumrepo('datadog')
        .with_enabled(1)\
        .with_gpgcheck(1)\
        .with_gpgkey('https://yum.datadoghq.com/DATADOG_RPM_KEY.public')\
        .with_baseurl('https://yum.datadoghq.com/rpm/x86_64/')
    end
  end
  context 'with manage_repo => false' do
    let(:params){ {:manage_repo => false} }
    it do
      should_not contain_yumrepo('datadog')
    end
  end


  # it should install the packages
  it do
    should contain_package('datadog-agent-base')\
      .with_ensure('absent')\
      .that_comes_before('Package[datadog-agent]')
  end
  it do
    should contain_package('datadog-agent')\
      .with_ensure('latest')
  end

  # it should be able to start the service and enable the service by default
  it do
    should contain_service('datadog-agent')\
      .that_requires('Package[datadog-agent]')
  end
end
