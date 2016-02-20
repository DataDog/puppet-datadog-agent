require 'spec_helper'

describe 'datadog_agent::integrations::marathon' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/marathon.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0644',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{default_timeout: 5}) }
    it { should contain_file(conf_file).with_content(%r{url: http://localhost:8080}) }
  end

  context 'with params set' do
    let(:params) {{
      marathon_timeout: 867,
      url: 'http://foo.bar.baz:5309',
    }}

    it { should contain_file(conf_file).with_content(%r{default_timeout: 867}) }
    it { should contain_file(conf_file).with_content(%r{url: http://foo.bar.baz:5309}) }
  end
end
