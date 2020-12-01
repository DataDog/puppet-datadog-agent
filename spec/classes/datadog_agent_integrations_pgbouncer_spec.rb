require 'spec_helper'

describe 'datadog_agent::integrations::pgbouncer' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/pgbouncer.yaml'
                  else
                    "#{CONF_DIR}/pgbouncer.d/conf.yaml"
                  end

      context 'with default parameters' do
        let(:params) do
          {
            password: 'foobar',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 6432}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: foobar}) }

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
      end

      context 'with one pgbouncer config parameters' do
        let(:params) do
          {
            host: 'localhost',
            username:  'foo',
            port: '1234',
            password: 'bar',
            tags: ['foo:bar'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{username: foo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: ("|')?1234("|')?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{- ("|')?foo:bar("|')?}) }
      end

      context 'with multiple pgbouncers configured' do
        let(:params) do
          {
            pgbouncers: [
              {
                'host'      => 'localhost',
                'username'  => 'datadog',
                'port'      => '6432',
                'password'  => 'some_pass',
                'tags'      => ['instance:one'],
              },
              {
                'host'      => 'localhost',
                'username'  => 'datadog2',
                'port'      => '6433',
                'password'  => 'some_pass2',
                'tags'      => ['instance:two'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: ("|')?6432("|')?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: some_pass}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{- ("|')?instance:one("|')?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: ("|')?6433("|')?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: some_pass2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{- ("|')?instance:two("|')?}) }
      end
    end
  end
end
