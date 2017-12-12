require 'spec_helper'

describe 'datadog_agent::integrations::cassandra' do
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
      let(:conf_file) { "#{conf_dir}/cassandra.yaml" }

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
