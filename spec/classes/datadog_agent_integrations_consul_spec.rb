require 'spec_helper'

describe 'datadog_agent::integrations::consul' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/consul.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/consul.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with defaults' do
        it { should contain_file(conf_file).with_content(%r{url: http://localhost:8500}) }
        it { should contain_file(conf_file).with_content(%r{catalog_checks: yes}) }
        it { should contain_file(conf_file).with_content(%r{new_leader_checks: yes}) }
        it { should contain_file(conf_file).with_content(%r{network_latency_checks: yes}) }
      end

      context 'with everything disabled' do
        let(:params) {{
          'url' => 'http://localhost:8005',
          'catalog_checks' => false,
          'new_leader_checks' => false,
          'network_latency_checks' => false,
        }}
        it { should contain_file(conf_file).with_content(%r{url: http://localhost:8005}) }
        it { should contain_file(conf_file).with_content(%r{catalog_checks: no}) }
        it { should contain_file(conf_file).with_content(%r{new_leader_checks: no}) }
        it { should contain_file(conf_file).with_content(%r{network_latency_checks: no}) }
      end

      context 'with service whitelist' do
        let(:params) {{
          'service_whitelist' => ['foo', 'bar']
        }}
        it { should contain_file(conf_file).with_content(%r{url: http://localhost:8500}) }
        it { should contain_file(conf_file).with_content(%r{service_whitelist:[\r\n]+\s+- foo[\r\n]+\s+- bar}) }
      end
    end
  end
end
