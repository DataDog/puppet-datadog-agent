require 'spec_helper'

describe 'datadog_agent::integrations::zk' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/zk.yaml'
                  else
                    "#{CONF_DIR}/zk.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 2181}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 3}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags:}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            servers: [
              {
                'host' => 'zookeeper1',
                'port' => '1234',
                'tags' => ['foo', 'bar'],
              },
              {
                'host' => 'zookeeper2',
                'port' => '4567',
                'tags' => ['baz', 'bat'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: zookeeper1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 1234}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{host: zookeeper2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 4567}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- baz\s+- bat}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{host: zookeeper1.+host: zookeeper2}m) }
      end
    end
  end
end
