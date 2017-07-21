require 'spec_helper'

describe 'datadog_agent::integrations::memcache' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/mcache.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}

  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{url: localhost}) }
    it { should contain_file(conf_file).without_content(/tags:/) }
  end

  context 'with parameters set' do
    let(:params) {{
      url: 'foobar',
      port: '11212',
      items: 'true',
      slabs: 'true',
      tags: %w{foo bar baz},
    }}
    it { should contain_file(conf_file).with_content(%r{url: foobar}) }
    it { should contain_file(conf_file).with_content(/port: 11212/) }
    it { should contain_file(conf_file).with_content(/items: true/) }
    it { should contain_file(conf_file).with_content(/slabs: true/) }
  end

  context 'with tags parameter single value' do
    let(:params) {{
      tags: 'foo',
    }}
    it { should_not compile }

    skip "this is currently unimplemented behavior" do
      it { should contain_file(conf_file).with_content(/tags:\s+- foo\s*?[^-]/m) }
    end
  end

  context 'with tags parameter array' do
    let(:params) {{
      tags: %w{ foo bar baz },
    }}
    it { should contain_file(conf_file).with_content(/tags:\s+- foo\s+- bar\s+- baz\s*?[^-]/m) }
  end

  context 'with tags parameter empty values' do
    context 'mixed in with other tags' do
      let(:params) {{
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

  context 'with multiple instances set' do
    let(:params) {
      {
        instances: [
          {
            'url'   => 'localhost',
            'port'  => '11211',
            'items' => true,
            'slabs' => true,
            'tags'  => ['tag1:value1'],
          },
          {
            'url'   => 'foo.bar',
            'port'  => '11212',
            'items' => false,
            'slabs' => false,
            'tags'  => ['tag2:value2'],
          }
        ]
      }
    }
    it { should contain_file(conf_file).with_content(%r{instances:}) }
    it { should contain_file(conf_file).with_content(%r{  - url: localhost}) }
    it { should contain_file(conf_file).with_content(%r{    port: 11211}) }
    it { should contain_file(conf_file).with_content(%r{    items: true}) }
    it { should contain_file(conf_file).with_content(%r{    slabs: true}) }
    it { should contain_file(conf_file).with_content(%r{    tags:}) }
    it { should contain_file(conf_file).with_content(%r{      - tag1:value1}) }
    it { should contain_file(conf_file).with_content(%r{  - url: foo.bar}) }
    it { should contain_file(conf_file).with_content(%r{    port: 11212}) }
    it { should contain_file(conf_file).with_content(%r{    items: false}) }
    it { should contain_file(conf_file).with_content(%r{    slabs: false}) }
    it { should contain_file(conf_file).with_content(%r{    tags:}) }
    it { should contain_file(conf_file).with_content(%r{      - tag2:value2}) }
  end
end
