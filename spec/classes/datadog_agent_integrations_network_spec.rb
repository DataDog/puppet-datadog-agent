require 'spec_helper'

describe 'datadog_agent::integrations::network' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/network.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/network.d/conf.yaml" }
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
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )}
        it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

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
