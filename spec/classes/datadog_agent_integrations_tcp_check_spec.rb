require 'spec_helper'

describe 'datadog_agent::integrations::tcp_check' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/tcp_check.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).without_content(%r{checkname: }) }
    it { should contain_file(conf_file).without_content(%r{host: }) }
    it { should contain_file(conf_file).without_content(%r{port: }) }
    it { should contain_file(conf_file).without_content(%r{timeout: 1}) }
    it { should contain_file(conf_file).without_content(%{threshold: }) }
    it { should contain_file(conf_file).without_content(%r{window: }) }
    it { should contain_file(conf_file).without_content(%r{collect_response_time: true}) }
    it { should contain_file(conf_file).without_content(%r{skip_event: }) }
    it { should contain_file(conf_file).without_content(%r{tags: }) }
  end

  context 'with parameters set' do
    let(:params) {{
      checkname: 'foo.bar.baz',
      host: '127.0.0.1',
      port: 8080,
      timeout: 123,
      threshold: 456,
      window: 789,
      collect_response_time: false,
      skip_event: true,
    }}

    it { should contain_file(conf_file).with_content(%r{checkname: foo.bar.baz}) }
    it { should contain_file(conf_file).with_content(%r{host: 127.0.0.1}) }
    it { should contain_file(conf_file).with_content(%r{port: 8080}) }
    it { should contain_file(conf_file).with_content(%r{timeout: 123}) }
    it { should contain_file(conf_file).with_content(%r{threshold: 456}) }
    it { should contain_file(conf_file).with_content(%r{window: 789}) }
    it { should contain_file(conf_file).with_content(%r{skip_event: true}) }
  end

  context 'with headers parameter empty values' do
    context 'mixed in with other headers' do
      let(:params) {{
        checkname: 'foo.bar.baz',
        host: 'localhost',
        port: 8080,
      }}

      it { should contain_file(conf_file).with_content(/headers:\s+foo\s+baz\s*?[^-]/m) }
    end

  context 'with tags parameter array' do
    let(:params) {{
      checkname: 'foo.bar.baz',
      host: '127.0.0.1',
      port: 8080,
      tags: %w{ foo bar baz },
    }}
    it { should contain_file(conf_file).with_content(/tags:\s+- foo\s+- bar\s+- baz\s*?[^-]/m) }
  end

  context 'with tags parameter empty values' do
    context 'mixed in with other tags' do
      let(:params) {{
        checkname: 'foo.bar.baz',
        host: '127.0.0.1',
        port: 8080,
        tags: [ 'foo', '', 'baz' ],
      }}

      it { should contain_file(conf_file).with_content(/tags:\s+- foo\s+- baz\s*?[^-]/m) }
    end

    context 'single element array of an empty string' do
      let(:params) {{
        tags: [''],
      }}

      skip("undefined behavior")
    end

    context 'single value empty string' do
      let(:params) {{
        tags: '',
      }}

      skip("doubly undefined behavior")
    end
  end
end
