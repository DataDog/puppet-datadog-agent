require 'spec_helper'

describe 'datadog_agent::integrations::zk' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/zk.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/zk.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_PROTECTED_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

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
  end
end
