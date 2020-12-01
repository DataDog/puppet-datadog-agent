require 'spec_helper'

describe 'datadog_agent::integrations::marathon' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/marathon.yaml'
                  else
                    "#{CONF_DIR}/marathon.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).with_content(%r{default_timeout: 5}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://localhost:8080}) }
      end

      context 'with params set' do
        let(:params) do
          {
            marathon_timeout: 867,
            url: 'http://foo.bar.baz:5309',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{default_timeout: 867}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://foo.bar.baz:5309}) }
      end
    end
  end
end
