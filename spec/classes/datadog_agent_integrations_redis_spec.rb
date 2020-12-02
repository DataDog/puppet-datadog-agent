require 'spec_helper'

describe 'datadog_agent::integrations::redis' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/redisdb.yaml'
                  else
                    "#{CONF_DIR}/redisdb.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 6379}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{^[^#]*password: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{^[^#]*slowlog-max-len: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{\bkeys:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{warn_on_missing_keys: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{command_stats: false}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            host: 'redis1',
            password: 'hunter2',
            port: 867,
            slowlog_max_len: 5309,
            tags: ['foo', 'bar'],
            keys: ['baz', 'bat'],
            warn_on_missing_keys: false,
            command_stats: true,
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: redis1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 867}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{warn_on_missing_keys: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{command_stats: true}) }
      end

      context 'with ports parameters set' do
        let(:params) do
          {
            host: 'redis1',
            password: 'hunter2',
            ports: ['2379', '2380', '2381'],
            slowlog_max_len: 5309,
            tags: ['foo', 'bar'],
            keys: ['baz', 'bat'],
            warn_on_missing_keys: false,
            command_stats: true,
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: redis1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{warn_on_missing_keys: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{command_stats: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 2379}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 2380}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 2381}) }
      end

      context 'with strings instead of ints' do
        let(:params) do
          {
            host: 'redis1',
            password: 'hunter2',
            port: '867',
            slowlog_max_len: '5309',
            tags: ['foo', 'bar'],
            keys: ['baz', 'bat'],
            warn_on_missing_keys: false,
            command_stats: true,
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: redis1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 867}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{warn_on_missing_keys: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{command_stats: true}) }
      end

      context 'with instances set' do
        let(:params) do
          {
            instances: [
              {
                'host' => 'redis1',
                'password' => 'hunter2',
                'port'     => 2379,
                'tags'     => ['foo', 'bar'],
                'keys'     => ['baz', 'bat'],
              },
              {
                'host'     => 'redis1',
                'password' => 'hunter2',
                'port'     => 2380,
                'tags'     => ['foo', 'bar'],
                'keys'     => ['baz', 'bat'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: redis1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 2379}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 2380}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{warn_on_missing_keys: false}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{command_stats: true}) }
      end

      context 'with only keys' do
        let(:params) do
          {
            instances: [
              {
                'host'     => 'redis1',
                'password' => 'hunter2',
                'port'     => 2379,
                'tags'     => [],
                'keys'     => ['baz', 'bat'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: redis1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 2379}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
      end

      context 'with only tags' do
        let(:params) do
          {
            instances: [
              {
                'host'     => 'redis1',
                'password' => 'hunter2',
                'port'     => 2379,
                'tags'     => ['baz', 'bat'],
                'keys'     => [],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: redis1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 2379}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:.*\s+- baz\s+- bat}) }
      end
    end
  end
end
