require 'spec_helper'

describe 'datadog_agent::integrations::mesos_master' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/mesos_master.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0644',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{default_timeout: 10}) }
    it { should contain_file(conf_file).with_content(%r{url: http://localhost:5050}) }
  end

  context 'with parameters set' do
    let(:params) {{
      mesos_timeout: 867,
      url: 'http://foo.bar.baz:5309',
    }}
    it { should contain_file(conf_file).with_content(%r{default_timeout: 867}) }
    it { should contain_file(conf_file).with_content(%r{url: http://foo.bar.baz:5309}) }
  end
end
