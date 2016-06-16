require 'spec_helper'

describe 'datadog_agent::integrations::fluentd' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/fluentd.yaml" }

  context 'with default parameters' do
    it { should compile }
  end

  context 'with monitor_agent_url set' do
    let(:params) {{
      monitor_agent_url: 'foobar',
    }}

    it { should compile.with_all_deps }
    it { should contain_file(conf_file).with(
      owner: dd_user,
      group: dd_group,
      mode: '0600',
    )}
    it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
    it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

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
