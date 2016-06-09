require 'spec_helper'

describe 'datadog_agent::integrations::kong' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/kong.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0644',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{kong_status_url: http://localhost:8001/status/}) }
  end

  context 'with params set' do
    let(:params) {{
      instances: [
        {
          'status_url' => 'http://foo.bar:8080/status/',
          'tags' => ['baz']
        }
      ]
    }}

    it { should contain_file(conf_file).with_content(%r{tags:\n.*- baz}) }
    it { should contain_file(conf_file).with_content(%r{kong_status_url: http://foo.bar:8080/status/}) }
  end
end
