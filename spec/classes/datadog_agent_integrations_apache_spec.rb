require 'spec_helper'

describe 'datadog_agent::integrations::apache' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      let(:agent5_enable) { is_agent5 }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/apache.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/apache.d/conf.yaml" }
      end
  
      it { should compile.with_all_deps }

      it { should contain_class('datadog_agent') }
      it { should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0600',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }
  
      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{apache_status_url: http://localhost/server-status\?auto}) }
        it { should contain_file(conf_file).without_content(/tags:/) }
        it { should contain_file(conf_file).without_content(/apache_user:/) }
        it { should contain_file(conf_file).without_content(/apache_password:/) }
      end
  
      context 'with parameters set' do
        let(:params) {{
          url: 'http://foobar',
          username: 'userfoo',
          password: 'passfoo',
          tags: %w{foo bar baz},
        }}
        it { should contain_file(conf_file).with_content(%r{apache_status_url: http://foobar}) }
        it { should contain_file(conf_file).with_content(/apache_user: userfoo/) }
        it { should contain_file(conf_file).with_content(/apache_password: passfoo/) }
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
    end
  end
end
