require 'spec_helper'

describe 'datadog_agent::integrations::mysql' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/mysql.yaml" }

  context 'with default parameters' do
    it { should_not compile }
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
