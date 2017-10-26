require 'spec_helper'

describe 'datadog_agent::integrations::pgbouncer' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => false, '6' => true }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent6_enable => #{enabled}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if !enabled
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      let(:conf_file) { "#{conf_dir}/pgbouncer.yaml" }


      context 'with default parameters' do
        let(:params) {{
          password: 'foobar',
        }}
        it { should contain_file(conf_file).with_content(%r{host: localhost}) }
        it { should contain_file(conf_file).with_content(%r{port: 6432}) }
        it { should contain_file(conf_file).with_content(%r{password: foobar}) }

        it { should compile.with_all_deps }
        it { should contain_file(conf_file).with(
          owner: dd_user,
          group: dd_group,
          mode: '0600',
        )}
        it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }
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
