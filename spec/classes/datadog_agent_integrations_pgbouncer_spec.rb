require 'spec_helper'

describe 'datadog_agent::integrations::pgbouncer' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/pgbouncer.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/pgbouncer.d/conf.yaml" }
      end

      context 'with default parameters' do
        let(:params) {{
          password: 'foobar',
        }}
        it { should contain_file(conf_file).with_content(%r{host: localhost}) }
        it { should contain_file(conf_file).with_content(%r{port: 6432}) }
        it { should contain_file(conf_file).with_content(%r{password: foobar}) }

        it { should compile.with_all_deps }
        it { should contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )}
        it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }
      end

      context 'with one pgbouncer config parameters' do
        let(:params) {{
          host: 'localhost',
          username:  'foo',
          port: '1234',
          password: 'bar',
          tags: ['foo:bar'],
        }}
        it { should contain_file(conf_file).with_content(%r{host: localhost}) }
        it { should contain_file(conf_file).with_content(%r{username: foo}) }
        it { should contain_file(conf_file).with_content(%r{port: ("|')?1234("|')?}) }
        it { should contain_file(conf_file).with_content(%r{password: bar}) }
        it { should contain_file(conf_file).with_content(%r{- ("|')?foo:bar("|')?}) }
      end

      context 'with multiple pgbouncers configured' do
        let(:params) {{
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
            }
          ]
        }}
        it { should contain_file(conf_file).with_content(%r{host: localhost}) }
        it { should contain_file(conf_file).with_content(%r{port: ("|')?6432("|')?}) }
        it { should contain_file(conf_file).with_content(%r{password: some_pass}) }
        it { should contain_file(conf_file).with_content(%r{- ("|')?instance:one("|')?}) }
        it { should contain_file(conf_file).with_content(%r{port: ("|')?6433("|')?}) }
        it { should contain_file(conf_file).with_content(%r{password: some_pass2}) }
        it { should contain_file(conf_file).with_content(%r{- ("|')?instance:two("|')?}) }
      end
    end
  end
end
