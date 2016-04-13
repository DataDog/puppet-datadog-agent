require 'spec_helper'

describe 'datadog_agent::integrations::redis' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/redisdb.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{host: localhost}) }
    it { should contain_file(conf_file).without_content(%r{^[^#]*password: }) }
    it { should contain_file(conf_file).with_content(%r{port: 6379}) }
    it { should contain_file(conf_file).without_content(%r{^[^#]*slowlog-max-len: }) }
    it { should contain_file(conf_file).without_content(%r{tags:}) }
    it { should contain_file(conf_file).without_content(%r{\bkeys:}) }
    it { should contain_file(conf_file).with_content(%r{warn_on_missing_keys: true}) }
  end

  context 'with parameters set' do
    let(:params) {{
      host: 'redis1',
      password: 'hunter2',
      port: 867,
      slowlog_max_len: '5309',
      tags: %w{foo bar},
      keys: %w{baz bat},
      warn_on_missing_keys: false,
    }}
    it { should contain_file(conf_file).with_content(%r{host: redis1}) }
    it { should contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
    it { should contain_file(conf_file).with_content(%r{port: 867}) }
    it { should contain_file(conf_file).with_content(%r{^[^#]*slowlog-max-len: 5309}) }
    it { should contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
    it { should contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
    it { should contain_file(conf_file).with_content(%r{warn_on_missing_keys: false}) }
  end

end
