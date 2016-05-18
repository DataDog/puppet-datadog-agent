require 'spec_helper'

describe 'datadog_agent::integrations::mongo' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/mongo.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{- server: mongodb://localhost:27017}) }
    it { should contain_file(conf_file).without_content(%r{tags:}) }
  end

  context 'with one mongo' do
    let(:params) {{
      servers: [
        {
          'host' => '127.0.0.1',
          'port' => '12345',
          'tags' => %w{ foo bar baz },
        }
      ]
    }}

    it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz}) }
  end

  context 'with multiple mongos' do
    let(:params) {{
      servers: [
        {
          'host' => '127.0.0.1',
          'port' => '34567',
          'tags' => %w{foo bar},
        },
        {
          'host' => '127.0.0.2',
          'port' => '45678',
          'tags' => %w{baz bat},
        }
      ]
    }}
    it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:34567/\s+tags:\s+- foo\s+- bar}) }
    it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.2:45678/\s+tags:\s+- baz\s+- bat}) }
    it { should contain_file(conf_file).with_content(%r{server:.*127.0.0.1.*server:.*127.0.0.2}m) }
  end

  context 'without tags' do
    let(:params) {{
      servers: [
        {
          'host' => '127.0.0.1',
          'port' => '12345',
        }
      ]
    }}

  end

  context 'weird tags' do
    let(:params) {{
      servers: [
        {
          'host' => '127.0.0.1',
          'port' => '56789',
          'tags' => 'word'
        }
      ]
    }}
    it { should_not compile }
  end
end
