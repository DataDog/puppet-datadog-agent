require 'spec_helper'

describe 'datadog_agent::integrations::consul' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/consul.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/consul.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0644',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

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
        it { should contain_file(conf_file).with_content(%r{service_whitelist:\n\s+- foo\n\s+- bar}) }
      end
    end
  end
end
