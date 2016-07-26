require 'spec_helper'

describe 'datadog_agent::integrations::cassandra' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/cassandra.yaml" }

  context 'with password set' do
    let(:params) {{
      user: 'datadog',
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
