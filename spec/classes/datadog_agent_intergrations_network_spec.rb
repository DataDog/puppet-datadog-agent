require 'spec_helper'

describe 'datadog_agent::integrations::network' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{enabled}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if enabled
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if enabled
        let(:conf_file) { "#{conf_dir}/network.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/network.d/conf.yaml" }
      end

      context 'with default parameters' do
        it { should compile }
      end

      context 'with collect_connection_state set' do
        let(:params) {{
          collect_connection_state: true,
        }}

        it { should compile.with_all_deps }
        it { should contain_file(conf_file).with(
          owner: dd_user,
          group: dd_group,
          mode: '0600',
        )}
        it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

        it { should contain_file(conf_file).with_content(%r{collect_connection_state: true}) }
        it { should contain_file(conf_file).without_content(%r{tags: }) }

        context 'with excluded_interfaces parameter array' do
          let(:params) {{
            excluded_interfaces: %w{ lo lo0 eth0 },
          }}
          it { should contain_file(conf_file).with_content(/excluded_interfaces:[^-]+- lo\s+- lo0\s+- eth0\s*?[^-]/m) }
        end
      end
    end
  end
end
