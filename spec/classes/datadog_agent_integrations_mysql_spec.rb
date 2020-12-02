require 'spec_helper'

describe 'datadog_agent::integrations::mysql' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/mysql.yaml'
                  else
                    "#{CONF_DIR}/mysql.d/conf.yaml"
                  end

      context 'with default parameters' do
        it { is_expected.to compile }
      end

      context 'with password set' do
        let(:params) do
          {
            password: 'foobar',
          }
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

        it { is_expected.to contain_file(conf_file).with_content(%r{pass: foobar}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags: }) }

        context 'with defaults' do
          it { is_expected.to contain_file(conf_file).with_content(%r{server: localhost}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{user: datadog}) }
          it { is_expected.to contain_file(conf_file).without_content(%r{sock: }) }
          it { is_expected.to contain_file(conf_file).with_content(%r{replication: 0}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{galera_cluster: 0}) }
        end
      end

      context 'with parameters set' do
        let(:params) do
          {
            password: 'foobar',
            host: 'mysql1',
            user: 'baz',
            sock: '/tmp/mysql.foo.sock',
            replication: '1',
            galera_cluster: '1',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{pass: foobar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{server: mysql1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{user: baz}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{sock: /tmp/mysql.foo.sock}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{replication: 1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{galera_cluster: 1}) }
      end

      context 'with tags parameter array' do
        let(:params) do
          {
            password: 'foobar',
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags:[^-]+- foo\s+- bar\s+- baz\s*?[^-]}m) }
      end

      context 'tags not array' do
        let(:params) do
          {
            password: 'foobar',
            tags: 'aoeu',
          }
        end

        it { is_expected.not_to compile }
      end

      context 'with queries parameter set' do
        let(:params) do
          {
            password: 'foobar',
            queries: [
              {
                'query'  => 'SELECT TIMESTAMPDIFF(second,MAX(create_time),NOW()) as last_accessed FROM requests',
                'metric' => 'app.seconds_since_last_request',
                'type'   => 'gauge',
                'field'  => 'last_accessed',
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{- query}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{query: SELECT TIMESTAMPDIFF\(second,MAX\(create_time\),NOW\(\)\) as last_accessed FROM requests}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{metric: app.seconds_since_last_request}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{type: gauge}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{field: last_accessed}) }
      end
    end
  end
end
