require 'spec_helper'

describe 'datadog_agent::integrations::cassandra' do
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
        let(:conf_file) { "#{conf_dir}/cassandra.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/cassandra.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_class('datadog_agent') }

      context 'with password set' do
        let(:params) {{
          user: 'datadog',
          password: 'foobar',
        }}

        it { should contain_file(conf_file).with(
          owner: dd_user,
          group: dd_group,
          mode: '0600',
        )}
        it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

        it { should contain_file(conf_file).with_content(%r{password: foobar}) }
        it { should contain_file(conf_file).without_content(%r{tags: }) }

        context 'with defaults' do
          it { should contain_file(conf_file).with_content(%r{host: localhost}) }
          it { should contain_file(conf_file).with_content(%r{user: datadog}) }
        end

        context 'with parameters set' do
          let(:params) {{
            password: 'foobar',
            host: 'cassandra1',
            user: 'baz',
          }}

          it { should contain_file(conf_file).with_content(%r{password: foobar}) }
          it { should contain_file(conf_file).with_content(%r{host: cassandra1}) }
          it { should contain_file(conf_file).with_content(%r{user: baz}) }
        end

        context 'with tags parameter hash' do
          let(:params) {{
            password: 'foobar',
            tags: {
                    'foo'=> 'bar',
                    'baz'=> 'ama',
            }
          }}
          it { should contain_file(conf_file).with_content(/tags:\s+foo: bar\s+baz: ama\s*?[^-]/m) }
        end

        context 'tags not hash' do
          let(:params) {{
            password: 'foobar',
            tags: 'aoeu',
          }}

          it { should_not compile }
        end
      end
    end
  end
end
