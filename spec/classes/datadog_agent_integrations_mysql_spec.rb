require 'spec_helper'

describe 'datadog_agent::integrations::mysql' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/mysql.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/mysql.d/conf.yaml" }
      end

      context 'with default parameters' do
        it { should compile }
      end

      context 'with password set' do
        let(:params) {{
          password: 'foobar',
        }}

        it { should compile.with_all_deps }
        it { should contain_file(conf_file).with(
          owner: dd_user,
          group: dd_group,
          mode: '0600',
        )}
        it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

        it { should contain_file(conf_file).with_content(%r{pass: foobar}) }
        it { should contain_file(conf_file).without_content(%r{tags: }) }

        context 'with defaults' do
          it { should contain_file(conf_file).with_content(%r{server: localhost}) }
          it { should contain_file(conf_file).with_content(%r{user: datadog}) }
          it { should contain_file(conf_file).without_content(%r{sock: }) }
          it { should contain_file(conf_file).with_content(%r{replication: 0}) }
          it { should contain_file(conf_file).with_content(%r{galera_cluster: 0}) }
        end

        context 'with parameters set' do
          let(:params) {{
            password: 'foobar',
            host: 'mysql1',
            user: 'baz',
            sock: '/tmp/mysql.foo.sock',
            replication: '1',
            galera_cluster: '1',
          }}

          it { should contain_file(conf_file).with_content(%r{pass: foobar}) }
          it { should contain_file(conf_file).with_content(%r{server: mysql1}) }
          it { should contain_file(conf_file).with_content(%r{user: baz}) }
          it { should contain_file(conf_file).with_content(%r{sock: /tmp/mysql.foo.sock}) }
          it { should contain_file(conf_file).with_content(%r{replication: 1}) }
          it { should contain_file(conf_file).with_content(%r{galera_cluster: 1}) }
        end

        context 'with tags parameter array' do
          let(:params) {{
            password: 'foobar',
            tags: %w{ foo bar baz },
          }}
          it { should contain_file(conf_file).with_content(/tags:[^-]+- foo\s+- bar\s+- baz\s*?[^-]/m) }
        end

        context 'tags not array' do
          let(:params) {{
            password: 'foobar',
            tags: 'aoeu',
          }}

          it { should_not compile }
        end
      end
    end

    context 'with queries parameter set' do
      let(:params) {{
        password: 'foobar',
        queries: [
          {
            'query'  => 'SELECT TIMESTAMPDIFF(second,MAX(create_time),NOW()) as last_accessed FROM requests',
            'metric' => 'app.seconds_since_last_request',
            'type'   => 'gauge',
            'field'  => 'last_accessed'
          }
        ]
      }}

      it { should contain_file(conf_file).with_content(/- query/) }
      it { should contain_file(conf_file).with_content(%r{query: SELECT TIMESTAMPDIFF\(second,MAX\(create_time\),NOW\(\)\) as last_accessed FROM requests}) }
      it { should contain_file(conf_file).with_content(%r{metric: app.seconds_since_last_request}) }
      it { should contain_file(conf_file).with_content(%r{type: gauge}) }
      it { should contain_file(conf_file).with_content(%r{field: last_accessed}) }
    end
  end
end
