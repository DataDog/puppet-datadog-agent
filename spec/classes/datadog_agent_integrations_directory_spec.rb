require 'spec_helper'

describe 'datadog_agent::integrations::directory' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/directory.yaml'
                  else
                    "#{CONF_DIR}/directory.d/conf.yaml"
                  end

      context 'with default parameters' do
        it { is_expected.not_to compile }
      end

      context 'with directory parameter set' do
        let(:params) do
          {
            directory: '/var/log/datadog',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_file(conf_file).with(
            owner: DD_USER,
            group: DD_GROUP,
            mode: PERMISSIONS_PROTECTED_FILE,
          )
        }

        it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
        it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

        context 'with default parameters' do
          it { is_expected.to contain_file(conf_file).with_content(%r{directory: /var/log/datadog}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{filegauges: false}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{recursive: true}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{countonly: false}) }
          it { is_expected.to contain_file(conf_file).without_content(%r{name:}) }
          it { is_expected.to contain_file(conf_file).without_content(%r{dirtagname:}) }
          it { is_expected.to contain_file(conf_file).without_content(%r{filetagname:}) }
          it { is_expected.to contain_file(conf_file).without_content(%r{pattern:}) }
        end

        context 'with parameters set' do
          let(:params) do
            {
              directory: '/var/log/datadog',
              nametag: 'doggielogs',
              dirtagname: 'doggiedirtag',
              filetagname: 'doggiefiletag',
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{directory: /var/log/datadog}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{name: doggielogs}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{dirtagname: doggiedirtag}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{filetagname: doggiefiletag}) }
        end
      end

      context 'with multiple instances set' do
        let(:params) do
          {
            instances: [
              {
                'directory'   => '/var/log/datadog',
              },
              {
                'directory'   => '/var/log/syslog',
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{instances:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{  - directory: /var/log/datadog}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{  - directory: /var/log/syslog}) }
      end
    end
  end
end
