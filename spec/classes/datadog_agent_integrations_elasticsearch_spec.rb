require 'spec_helper'

describe 'datadog_agent::integrations::elasticsearch' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/elastic.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0644',
  )}

  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{    - url: http://localhost:9200}) }
    it { should contain_file(conf_file).with_content(%r{      cluster_stats: false}) }
    it { should contain_file(conf_file).with_content(%r{      pending_task_stats: true}) }
    it { should contain_file(conf_file).with_content(%r{      pshard_stats: false}) }
    it { should_not contain_file(conf_file).with_content(%r{      username}) }
    it { should_not contain_file(conf_file).with_content(%r{      password}) }
    it { should_not contain_file(conf_file).with_content(%r{      ssl_verify}) }
    it { should_not contain_file(conf_file).with_content(%r{      ssl_cert}) }
    it { should_not contain_file(conf_file).with_content(%r{      ssl_key}) }
    it { should_not contain_file(conf_file).with_content(%r{      tags:}) }
  end
context 'with parameters set' do
    let(:params) {{
      password:           'password',
      pending_task_stats: false,
      url:                'https://foo:4242',
      username:           'username',
      ssl_cert:           '/etc/ssl/certs/client.pem',
      ssl_key:            '/etc/ssl/private/client.key',
      tags:               ['tag1:key1'],
    }}
    it { should contain_file(conf_file).with_content(%r{    - url: https://foo:4242}) }
    it { should contain_file(conf_file).with_content(%r{      pending_task_stats: false}) }
    it { should contain_file(conf_file).with_content(%r{      username: username}) }
    it { should contain_file(conf_file).with_content(%r{      password: password}) }
    it { should contain_file(conf_file).with_content(%r{      ssl_verify: true}) }
    it { should contain_file(conf_file).with_content(%r{      ssl_cert: /etc/ssl/certs/client.pem}) }
    it { should contain_file(conf_file).with_content(%r{      ssl_key: /etc/ssl/private/client.key}) }
    it { should contain_file(conf_file).with_content(%r{      tags:}) }
    it { should contain_file(conf_file).with_content(%r{        - tag1:key1}) }
  end

end
