require 'spec_helper'

describe 'datadog_agent::integrations::redis' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/redisdb.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/redisdb.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(%r{port: 6379}) }
        it { should contain_file(conf_file).without_content(%r{^[^#]*password: }) }
        it { should contain_file(conf_file).without_content(%r{^[^#]*slowlog-max-len: }) }
        it { should contain_file(conf_file).without_content(%r{tags:}) }
        it { should contain_file(conf_file).without_content(%r{\bkeys:}) }
        it { should contain_file(conf_file).with_content(%r{warn_on_missing_keys: true}) }
        it { should contain_file(conf_file).with_content(%r{command_stats: false}) }
      end

      context 'with parameters set' do
        let(:params) {{
          host: 'redis1',
          password: 'hunter2',
          port: 867,
          slowlog_max_len: 5309,
          tags: %w{foo bar},
          keys: %w{baz bat},
          warn_on_missing_keys: false,
          command_stats: true,
        }}
        it { should contain_file(conf_file).with_content(%r{host: redis1}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{port: 867}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { should contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { should contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { should contain_file(conf_file).with_content(%r{warn_on_missing_keys: false}) }
        it { should contain_file(conf_file).with_content(%r{command_stats: true}) }
      end

      context 'with ports parameters set' do
        let(:params) {{
          host: 'redis1',
          password: 'hunter2',
          ports: %w(2379 2380 2381),
          slowlog_max_len: 5309,
          tags: %w{foo bar},
          keys: %w{baz bat},
          warn_on_missing_keys: false,
          command_stats: true,
        }}
        it { should contain_file(conf_file).with_content(%r{host: redis1}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { should contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { should contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { should contain_file(conf_file).with_content(%r{warn_on_missing_keys: false}) }
        it { should contain_file(conf_file).with_content(%r{command_stats: true}) }
        it { should contain_file(conf_file).with_content(%r{port: 2379}) }
        it { should contain_file(conf_file).with_content(%r{port: 2380}) }
        it { should contain_file(conf_file).with_content(%r{port: 2381}) }
      end

      context 'with strings instead of ints' do
        let(:params) {{
          host: 'redis1',
          password: 'hunter2',
          port: '867',
          slowlog_max_len: '5309',
          tags: %w{foo bar},
          keys: %w{baz bat},
          warn_on_missing_keys: false,
          command_stats: true,
        }}
        it { should contain_file(conf_file).with_content(%r{host: redis1}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{port: 867}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { should contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { should contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { should contain_file(conf_file).with_content(%r{warn_on_missing_keys: false}) }
        it { should contain_file(conf_file).with_content(%r{command_stats: true}) }
      end

      context 'with instances set' do
        let(:params) {{
          instances: [
              {
                  'host'     => 'redis1',
                  'password' => 'hunter2',
                  'port'     => 2379,
                  'tags'     => %w(foo bar),
                  'keys'     => %w(baz bat),
              },
              {
                  'host'     => 'redis1',
                  'password' => 'hunter2',
                  'port'     => 2380,
                  'tags'     => %w(foo bar),
                  'keys'     => %w(baz bat),
              },
          ],
        }}
        it { should contain_file(conf_file).with_content(%r{host: redis1}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{port: 2379}) }
        it { should contain_file(conf_file).with_content(%r{port: 2380}) }
        it { should contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { should contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { should contain_file(conf_file).without_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { should contain_file(conf_file).without_content(%r{warn_on_missing_keys: false}) }
        it { should contain_file(conf_file).without_content(%r{command_stats: true}) }
      end

      context 'with only keys' do
        let(:params) {{
          instances: [
              {
                  'host'     => 'redis1',
                  'password' => 'hunter2',
                  'port'     => 2379,
                  'tags'     => %w(),
                  'keys'     => %w(baz bat),
              },
          ],
        }}
        it { should contain_file(conf_file).with_content(%r{host: redis1}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{port: 2379}) }
        it { should contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
      end

      context 'with only tags' do
        let(:params) {{
          instances: [
              {
                  'host'     => 'redis1',
                  'password' => 'hunter2',
                  'port'     => 2379,
                  'tags'     => %w(baz bat),
                  'keys'     => %w(),
              },
          ],
        }}
        it { should contain_file(conf_file).with_content(%r{host: redis1}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{port: 2379}) }
        it { should contain_file(conf_file).with_content(%r{tags:.*\s+- baz\s+- bat}) }
      end
    end
  end
end
