require 'spec_helper'

describe 'datadog_agent::reports' do
  if RSpec::Support::OS.windows?
    return
  end

  context 'all supported operating systems' do
    let(:params) do
      {
        api_key: 'notanapikey',
        puppetmaster_user: 'puppet',
        dogapi_version: 'installed',
      }
    end

    conf_file = '/etc/datadog-agent/datadog-reports.yaml'

    ALL_OS.each do |operatingsystem|
      describe "datadog_agent class common actions on #{operatingsystem}" do
        let(:facts) do
          {
            os: {
              'architecture' => 'x86_64',
              'family' => getosfamily(operatingsystem),
              'name' => operatingsystem,
              'release' => {
                'major' => getosmajor(operatingsystem),
                'full' => getosrelease(operatingsystem),
              },
            },
          }
        end

        if WINDOWS_OS.include?(operatingsystem)
          it 'raises on Windows' do
            is_expected.to raise_error(Puppet::Error)
          end
        else

          it { is_expected.to contain_package('ruby').with_ensure('installed') }
          it { is_expected.to contain_package('rubygems').with_ensure('installed') }

          if DEBIAN_OS.include?(operatingsystem)
            it do
              is_expected.to contain_package('ruby-dev')\
                .with_ensure('installed')\
                .that_comes_before('Package[dogapi]')
            end
          elsif REDHAT_OS.include?(operatingsystem)
            it do
              is_expected.to contain_package('ruby-devel')\
                .with_ensure('installed')\
                .that_comes_before('Package[dogapi]')
            end
          end

          it do
            is_expected.to contain_package('dogapi')\
              .with_ensure('installed')
              .with_provider('puppetserver_gem')
          end

          it do
            is_expected.to contain_file(conf_file)\
              .with_owner('puppet')\
              .with_group('root')
          end

          it { is_expected.to contain_file(conf_file).without_content(%r{hostname_extraction_regex:}) }

        end
      end
    end
  end
  context 'specific dogapi version' do
    let(:params) do
      {
        api_key: 'notanapikey',
        puppetmaster_user: 'puppet',
        dogapi_version: '1.2.2',
      }
    end

    conf_file = '/etc/datadog-agent/datadog-reports.yaml'

    describe 'datadog_agent class dogapi version override' do
      let(:facts) do
        {
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Debian',
            'release' => {
              'major' => '8',
              'full' => '8.1',
            },
          },
        }
      end

      it { is_expected.to contain_package('ruby').with_ensure('installed') }
      it { is_expected.to contain_package('rubygems').with_ensure('installed') }

      it do
        is_expected.to contain_package('ruby-dev')\
          .with_ensure('installed')\
          .that_comes_before('Package[dogapi]')
      end

      it do
        is_expected.to contain_package('dogapi')\
          .with_ensure('1.2.2')
          .with_provider('puppetserver_gem')
      end

      it do
        is_expected.to contain_file(conf_file)\
          .with_owner('puppet')\
          .with_group('root')
      end
    end
  end

  context 'specific gem provider' do
    let(:params) do
      {
        api_key: 'notanapikey',
        puppetmaster_user: 'puppet',
        dogapi_version: '1.2.2',
        puppet_gem_provider: 'gem',

      }
    end

    describe 'datadog_agent class puppet gem provider override' do
      let(:facts) do
        {
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Debian',
            'release' => {
              'major' => '8',
              'full' => '8.1',
            },
          },
        }
      end

      it { is_expected.to contain_package('ruby').with_ensure('installed') }
      it { is_expected.to contain_package('rubygems').with_ensure('installed') }

      it do
        is_expected.to contain_package('ruby-dev')\
          .with_ensure('installed')\
          .that_comes_before('Package[dogapi]')
      end

      it do
        is_expected.to contain_package('dogapi')\
          .with_ensure('1.2.2')
          .with_provider('gem')
      end
    end
  end

  context 'EU site in report' do
    let(:params) do
      {
        api_key: 'notanapikey',
        puppetmaster_user: 'puppet',
        dogapi_version: 'installed',
        datadog_site: 'https://api.datadoghq.eu',
      }
    end

    conf_file = '/etc/datadog-agent/datadog-reports.yaml'

    describe 'datadog_agent class dogapi version override' do
      let(:facts) do
        {
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Debian',
            'release' => {
              'major' => '8',
              'full' => '8.1',
            },
          },
        }
      end

      it { is_expected.to contain_package('ruby').with_ensure('installed') }
      it { is_expected.to contain_package('rubygems').with_ensure('installed') }

      it do
        is_expected.to contain_package('ruby-dev')\
          .with_ensure('installed')\
          .that_comes_before('Package[dogapi]')
      end

      it do
        is_expected.to contain_file(conf_file)\
          .with_owner('puppet')\
          .with_group('root')\
          .with_content(%r{:api_url: https://api.datadoghq.eu})
      end
      it { is_expected.to contain_file(conf_file).without_content(%r{hostname_extraction_regex:}) }
    end
  end

  context 'disabled ruby-manage' do
    let(:params) do
      {
        api_key: 'notanapikey',
        hostname_extraction_regex: nil,
        dogapi_version: 'installed',
        puppetmaster_user: 'puppet',
        puppet_gem_provider: 'gem',
        manage_dogapi_gem: false,
      }
    end

    describe 'datadog_agent class dogapi version override' do
      let(:facts) do
        {
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Debian',
            'release' => {
              'major' => '8',
              'full' => '8.1',
            },
          },
        }
      end

      it { is_expected.not_to contain_package('ruby').with_ensure('installed') }
      it { is_expected.not_to contain_package('rubygems').with_ensure('installed') }

      it { is_expected.not_to contain_package('ruby-dev') }

      it { is_expected.not_to contain_package('dogapi') }

      it do
        is_expected.to contain_file('/etc/datadog-agent/datadog-reports.yaml')\
          .with_owner('puppet')\
          .with_group('root')
      end
    end
  end
end
