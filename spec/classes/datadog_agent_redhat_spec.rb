require 'spec_helper'

describe 'datadog_agent::redhat' do
  context 'agent 5' do
    if RSpec::Support::OS.windows?
      return
    end

    let(:facts) do
      {
        os: {
          'architecture' => 'x86_64',
          'family' => 'redhat',
          'name' => 'Fedora',
          'release' => {
            'major' => '36',
            'full' => '36',
          },
        },
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public')\
          .with_baseurl('https://yum.datadoghq.com/rpm/x86_64/')\
          .with_repo_gpgcheck(false)
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
    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent')\
        .with_ensure('latest')
    end
  end

  context 'agent 6' do
    let(:facts) do
      {
        os: {
          'architecture' => 'x86_64',
          'family' => 'redhat',
          'name' => 'Fedora',
          'release' => {
            'major' => '36',
            'full' => '36',
          },
        },
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public')\
          .with_baseurl('https://yum.datadoghq.com/stable/6/x86_64/')\
          .with_repo_gpgcheck(true)
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

    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent')\
        .with_ensure('latest')
    end
  end

  context 'agent 7' do
    let(:facts) do
      {
        os: {
          'architecture' => 'x86_64',
          'family' => 'redhat',
          'name' => 'Fedora',
          'release' => {
            'major' => '36',
            'full' => '36',
          },
        },
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public')\
          .with_baseurl('https://yum.datadoghq.com/stable/7/x86_64/')\
          .with_repo_gpgcheck(true)
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

    # it should install the packages
    it do
      is_expected.to contain_package('datadog-agent')\
        .with_ensure('latest')
    end
  end

  context 'rhel 8.1' do
    # we expect repo_gpgcheck to be false on 8.1
    let(:facts) do
      {
        os: {
          'architecture' => 'x86_64',
          'family' => 'redhat',
          'name' => 'RedHat',
          'release' => {
            'major' => '8',
            'full' => '8.1',
          },
        },
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public')\
          .with_baseurl('https://yum.datadoghq.com/stable/7/x86_64/')\
          .with_repo_gpgcheck(false)
      end
    end
  end

  context 'rhel 8.2' do
    # we expect repo_gpgcheck to be true on 8.2 (and later)
    let(:facts) do
      {
        os: {
          'architecture' => 'x86_64',
          'family' => 'redhat',
          'name' => 'RedHat',
          'release' => {
            'major' => '8',
            'full' => '8.2',
          },
        },
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
        # we expect repo_gpgcheck to be false on 8.1
        is_expected.to contain_yumrepo('datadog')
          .with_enabled(1)\
          .with_gpgcheck(1)\
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public')\
          .with_baseurl('https://yum.datadoghq.com/stable/7/x86_64/')\
          .with_repo_gpgcheck(true)
      end
    end
  end

  context 'almalinux 8', if: min_puppet_version('7.12.0') do
    let(:facts) do
      {
        os: {
          'architecture' => 'x86_64',
          'family' => 'redhat',
          'name' => 'AlmaLinux',
          'release' => {
            'major' => '8',
            'full' => '8.5',
          },
        },
      }
    end

    # it should install the repo
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public')\
          .with_baseurl('https://yum.datadoghq.com/stable/7/x86_64/')\
          .with_repo_gpgcheck(true)
      end
    end
  end

  context 'rocky 8', if: min_puppet_version('7.12.0') do
    let(:facts) do
      {
        os: {
          'architecture' => 'x86_64',
          'family' => 'redhat',
          'name' => 'Rocky',
          'release' => {
            'major' => '8',
            'full' => '8.5',
          },
        },
      }
    end

    # it should install the repo
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
          .with_gpgkey('https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public
       https://keys.datadoghq.com/DATADOG_RPM_KEY_B01082D3.public')\
          .with_baseurl('https://yum.datadoghq.com/stable/7/x86_64/')\
          .with_repo_gpgcheck(true)
      end
    end
  end
end
