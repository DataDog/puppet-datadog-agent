require 'spec_helper'

describe 'datadog_agent::integrations::http_check' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/http_check.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).without_content(%r{name: }) }
    it { should contain_file(conf_file).without_content(%r{url: }) }
    it { should contain_file(conf_file).without_content(%r{username: }) }
    it { should contain_file(conf_file).without_content(%r{password: }) }
    it { should contain_file(conf_file).without_content(%r{timeout: 1}) }
    it { should contain_file(conf_file).without_content(%{threshold: }) }
    it { should contain_file(conf_file).without_content(%r{window: }) }
    it { should contain_file(conf_file).without_content(%r{content_match: }) }
    it { should contain_file(conf_file).without_content(%r{include_content: true}) }
    it { should contain_file(conf_file).without_content(%r{collect_response_time: true}) }
    it { should contain_file(conf_file).without_content(%r{disable_ssl_validation: false}) }
    it { should contain_file(conf_file).without_content(%r{headers: }) }
    it { should contain_file(conf_file).without_content(%r{tags: }) }
  end

  context 'with parameters set' do
    let(:params) {{
      sitename: 'foo.bar.baz',
      url: 'http://foo.bar.baz:4096',
      username: 'foouser',
      password: 'barpassword',
      timeout: 123,
      threshold: 456,
      window: 789,
      content_match: 'foomatch',
      include_content: true,
      collect_response_time: false,
      disable_ssl_validation: true,
    }}

    it { should contain_file(conf_file).with_content(%r{name: foo.bar.baz}) }
    it { should contain_file(conf_file).with_content(%r{url: http://foo.bar.baz:4096}) }
    it { should contain_file(conf_file).with_content(%r{username: foouser}) }
    it { should contain_file(conf_file).with_content(%r{password: barpassword}) }
    it { should contain_file(conf_file).with_content(%r{timeout: 123}) }
    it { should contain_file(conf_file).with_content(%r{threshold: 456}) }
    it { should contain_file(conf_file).with_content(%r{window: 789}) }
    it { should contain_file(conf_file).with_content(%r{content_match: foomatch}) }
    it { should contain_file(conf_file).with_content(%r{include_content: true}) }
    it { should contain_file(conf_file).without_content(%r{collect_response_time: true}) }
    it { should contain_file(conf_file).with_content(%r{disable_ssl_validation: true}) }
  end

  context 'with headers parameter array' do
    let(:params) {{
      sitename: 'foo.bar.baz',
      url: 'http://foo.bar.baz:4096',
      headers: %w{ foo bar baz },
    }}
    it { should contain_file(conf_file).with_content(/headers:\s+foo\s+bar\s+baz\s*?[^-]/m) }
  end

  context 'with headers parameter empty values' do
    context 'mixed in with other headers' do
      let(:params) {{
      sitename: 'foo.bar.baz',
        url: 'http://foo.bar.baz:4096',
        headers: [ 'foo', '', 'baz' ]
      }}

      it { should contain_file(conf_file).with_content(/headers:\s+foo\s+baz\s*?[^-]/m) }
    end

    context 'single element array of an empty string' do
      let(:params) {{
        headers: [''],
      }}

      skip("undefined behavior")
    end

    context 'single value empty string' do
      let(:params) {{
        headers: '',
      }}

      skip("doubly undefined behavior")
    end
  end


  context 'with tags parameter array' do
    let(:params) {{
      sitename: 'foo.bar.baz',
      url: 'http://foo.bar.baz:4096',
      tags: %w{ foo bar baz },
    }}
    it { should contain_file(conf_file).with_content(/tags:\s+- foo\s+- bar\s+- baz\s*?[^-]/m) }
  end

  context 'with tags parameter empty values' do
    context 'mixed in with other tags' do
      let(:params) {{
        sitename: 'foo.bar.baz',
        url: 'http://foo.bar.baz:4096',
        tags: [ 'foo', '', 'baz' ]
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

  context 'with contact set' do
    let(:params) {{
      contact: %r{alice bob carlo}
    }}

    # the parameter is '$contact' and the template uses '@contacts', so neither is used
    skip "this functionality appears to not be functional" do
      it { should contain_file(conf_file).with_content(%r{notify:\s+- alice\s+bob\s+carlo}) }
    end
  end
end
