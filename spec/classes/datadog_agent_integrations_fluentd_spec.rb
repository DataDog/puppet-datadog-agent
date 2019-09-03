require 'spec_helper'

describe 'datadog_agent::integrations::fluentd' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/fluentd.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/fluentd.d/conf.yaml" }
      end

      context 'with default parameters' do
        it { should compile }
      end

      context 'with monitor_agent_url set' do
        let(:params) {{
          monitor_agent_url: 'foobar',
        }}

        it { should compile.with_all_deps }
        it { should contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )}
        it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

        it { should contain_file(conf_file).with_content(%r{monitor_agent_url: foobar}) }
        it { should contain_file(conf_file).without_content(%r{tags: }) }

        context 'with plugin_ids parameter array' do
          let(:params) {{
            monitor_agent_url: 'foobar',
            plugin_ids: %w{ foo bar baz },
          }}
          it { should contain_file(conf_file).with_content(/plugin_ids:[^-]+- foo\s+- bar\s+- baz\s*?[^-]/m) }
        end

        context 'plugin_ids not array' do
          let(:params) {{
            monitor_agent_url: 'foobar',
            plugin_ids: 'aoeu',
          }}

          it { should_not compile }
        end
      end
    end
  end
end
