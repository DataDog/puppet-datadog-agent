require 'spec_helper'

describe 'datadog_agent::integrations::zk' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/zk.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{host: localhost}) }
    it { should contain_file(conf_file).with_content(%r{port: 2181}) }
    it { should contain_file(conf_file).with_content(%r{timeout: 3}) }
    it { should contain_file(conf_file).without_content(%r{tags:}) }
  end

  context 'with parameters set' do
    let(:params) {{
      servers: [
        {
          'host' => 'zookeeper1',
          'port' => '1234',
          'tags' => %w{foo bar},
        },
        {
          'host' => 'zookeeper2',
          'port' => '4567',
          'tags' => %w{baz bat},
        }
      ]
    }}
    it { should contain_file(conf_file).with_content(%r{host: zookeeper1}) }
    it { should contain_file(conf_file).with_content(%r{port: 1234}) }
    it { should contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar}) }
    it { should contain_file(conf_file).with_content(%r{host: zookeeper2}) }
    it { should contain_file(conf_file).with_content(%r{port: 4567}) }
    it { should contain_file(conf_file).with_content(%r{tags:\s+- baz\s+- bat}) }
    it { should contain_file(conf_file).with_content(%r{host: zookeeper1.+host: zookeeper2}m) }
  end
end
