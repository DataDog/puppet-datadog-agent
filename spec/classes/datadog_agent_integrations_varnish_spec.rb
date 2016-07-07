require 'spec_helper'

describe 'datadog_agent::integrations::varnish' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/varnish.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }


  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{varnishstat: /usr/bin/varnishstat}) }
    it { should contain_file(conf_file).without_content(%r{tags: }) }
  end

  context 'with parameters set' do
    let(:params){{
      varnishstat: '/opt/bin/varnishstat',
      tags: %w{ foo bar baz },
    }}

    it { should contain_file(conf_file).with_content(%r{varnishstat: /opt/bin/varnishstat}) }
    it { should contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar\s+- baz}) }
  end
end
