require 'spec_helper'

describe 'datadog_agent::integrations::consul' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/consul.yaml'
                  else
                    "#{CONF_DIR}/consul.d/conf.yaml"
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

      context 'with defaults' do
        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://localhost:8500}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{catalog_checks: yes}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{new_leader_checks: yes}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{network_latency_checks: yes}) }
      end

      context 'with everything disabled' do
        let(:params) do
          {
            'url' => 'http://localhost:8005',
            'catalog_checks' => false,
            'new_leader_checks' => false,
            'network_latency_checks' => false,
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://localhost:8005}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{catalog_checks: no}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{new_leader_checks: no}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{network_latency_checks: no}) }
      end

      context 'with service whitelist' do
        let(:params) do
          {
            'service_whitelist' => ['foo', 'bar'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://localhost:8500}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{service_whitelist:[\r\n]+\s+- foo[\r\n]+\s+- bar}) }
      end
    end
  end
end
