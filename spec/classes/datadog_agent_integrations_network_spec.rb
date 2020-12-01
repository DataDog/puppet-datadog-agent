require 'spec_helper'

describe 'datadog_agent::integrations::network' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/network.yaml'
                  else
                    "#{CONF_DIR}/network.d/conf.yaml"
                  end

      context 'with default parameters' do
        it { is_expected.to compile }
      end

      context 'with collect_connection_state set' do
        let(:params) do
          {
            collect_connection_state: true,
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

        it { is_expected.to contain_file(conf_file).with_content(%r{collect_connection_state: true}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags: }) }

        context 'with excluded_interfaces parameter array' do
          let(:params) do
            {
              excluded_interfaces: ['lo', 'lo0', 'eth0'],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{excluded_interfaces:[^-]+- lo\s+- lo0\s+- eth0\s*?[^-]}m) }
        end
      end
    end
  end
end
