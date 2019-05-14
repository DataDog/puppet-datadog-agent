require 'spec_helper'

describe 'datadog_agent::integrations::tcp_check' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/tcp_check.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/tcp_check.d/conf.yaml" }
      end

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
        it { should contain_file(conf_file).without_content(%r{host: }) }
        it { should contain_file(conf_file).without_content(%r{port: }) }
        it { should contain_file(conf_file).without_content(%r{timeout: 1}) }
        it { should contain_file(conf_file).without_content(%{threshold: }) }
        it { should contain_file(conf_file).without_content(%r{window: }) }
        it { should contain_file(conf_file).without_content(%r{collect_response_time: }) }
        it { should contain_file(conf_file).without_content(%r{skip_event: }) }
        it { should contain_file(conf_file).without_content(%r{tags: }) }
      end

      context 'with parameters set' do
        let(:params) {{
          check_name: 'foo.bar.baz',
          host: 'foo.bar.baz',
          port: '80',
          timeout: 123,
          threshold: 456,
          window: 789,
          collect_response_time: true,
          skip_event: true,
        }}

        it { should contain_file(conf_file).with_content(%r{name: foo.bar.baz}) }
        it { should contain_file(conf_file).with_content(%r{host: foo.bar.baz}) }
        it { should contain_file(conf_file).with_content(%r{port: 80}) }
        it { should contain_file(conf_file).with_content(%r{timeout: 123}) }
        it { should contain_file(conf_file).with_content(%r{threshold: 456}) }
        it { should contain_file(conf_file).with_content(%r{window: 789}) }
        it { should contain_file(conf_file).with_content(%r{collect_response_time: true}) }
        it { should contain_file(conf_file).with_content(%r{skip_event: true}) }
      end

      context 'with tags parameter array' do
        let(:params) {{
          check_name: 'foo.bar.baz',
          host: 'foo.bar.baz',
          port: '80',
          tags: [ 'foo', 'bar', 'baz' ],
        }}
        it { should contain_file(conf_file).with_content(/tags:\s+- foo\s+- bar\s+- baz\s*?[^-]/m) }
      end

      context 'with tags parameter empty values' do
        context 'mixed in with other tags' do
          let(:params) {{
            check_name: 'foo.bar.baz',
            host: 'foo.bar.baz',
            port: '80',
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
