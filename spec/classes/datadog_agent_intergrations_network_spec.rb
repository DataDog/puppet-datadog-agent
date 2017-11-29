require 'spec_helper'

describe 'datadog_agent::integrations::network' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/network.yaml" }

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
