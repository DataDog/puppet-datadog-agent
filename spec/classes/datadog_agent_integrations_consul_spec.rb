require 'spec_helper'

describe 'datadog_agent::integrations::consul' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/consul_check.yaml" }
  let(:legacy_conf_file) {"#{conf_dir}/consul.yaml"}

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }
  it { should contain_file(legacy_conf_file).with_ensure('absent')}

  context 'with custom consul_check_filename' do
    let(:params) {{
      consul_check_filename: 'nonsense.yaml'
    }}
    it { should contain_file("#{conf_dir}/nonsense.yaml") }
  end

  context 'with agent version latest' do
    let(:params) {{
      agent_version: 'latest'
    }}
    it { should contain_file(conf_file) }
    it { should contain_file(legacy_conf_file).with_ensure('absent')}
  end

  context 'with agent version 5.7.0' do
    let(:params) {{
      agent_version: '5.7.0'
    }}
    it { should contain_file(legacy_conf_file) }
  end

  context 'with agent version 1:5.7.0' do
    let(:params) {{
      agent_version: '1:5.7.0'
    }}
    it { should contain_file(legacy_conf_file) }
  end

  context 'with agent version 5.8.0' do
    let(:params) {{
      agent_version: '5.8.0'
    }}
    it { should contain_file(conf_file) }
    it { should contain_file(legacy_conf_file).with_ensure('absent')}
  end
  
  context 'with agent version 1:5.8.0' do
    let(:params) {{
      agent_version: '1:5.8.0'
    }}
    it { should contain_file(conf_file) }
    it { should contain_file(legacy_conf_file).with_ensure('absent')}
  end
end
