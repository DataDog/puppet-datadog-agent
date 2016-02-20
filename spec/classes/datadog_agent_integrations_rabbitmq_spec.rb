require 'spec_helper'

describe 'datadog_agent::integrations::rabbitmq' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/rabbitmq.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{rabbitmq_api_url: }) }
    it { should contain_file(conf_file).without_content(%r{rabbitmq_user: }) }
    it { should contain_file(conf_file).without_content(%r{rabbitmq_pass: }) }
    it { should contain_file(conf_file).without_content(%r{queues: }) }
    it { should contain_file(conf_file).without_content(%r{vhosts: }) }
  end

  context 'with parameters set' do
    let(:params) {{
      url: 'http://rabbit1:15672/',
      username: 'foo',
      password: 'bar',
      queues: %w{ queue1 queue2 queue3 },
      vhosts: %w{ vhost1 vhost2 vhost3 },
    }}
    it { should contain_file(conf_file).with_content(%r{rabbitmq_api_url: http://rabbit1:15672/}) }
    it { should contain_file(conf_file).with_content(%r{rabbitmq_user: foo}) }
    it { should contain_file(conf_file).with_content(%r{rabbitmq_pass: bar}) }
    it { should contain_file(conf_file).with_content(%r{queues:\s+- queue1\s+- queue2\s+- queue3}) }
    it { should contain_file(conf_file).with_content(%r{vhosts:\s+- vhost1\s+- vhost2\s+- vhost3}) }
  end
end
