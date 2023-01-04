require 'spec_helper'

describe 'datadog_agent::integrations::process' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/process.yaml'
                  else
                    "#{CONF_DIR}/process.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).without_content(%r{^[^#]*name:}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            processes: [
              {
                'name' => 'foo',
                'search_string' => 'bar',
                'exact_match' => true,
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{name: foo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{search_string: bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{exact_match: true}) }
      end
    end
  end
end
