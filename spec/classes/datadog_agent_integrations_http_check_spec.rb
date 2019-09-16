require 'spec_helper'

describe 'datadog_agent::integrations::http_check' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/http_check.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/http_check.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_PROTECTED_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).without_content(%r{name: }) }
        it { should contain_file(conf_file).without_content(%r{url: }) }
        it { should contain_file(conf_file).without_content(%r{username: }) }
        it { should contain_file(conf_file).without_content(%r{password: }) }
        it { should contain_file(conf_file).without_content(%r{timeout: 1}) }
        it { should contain_file(conf_file).without_content(%r{data: }) }
        it { should contain_file(conf_file).without_content(%{threshold: }) }
        it { should contain_file(conf_file).without_content(%r{window: }) }
        it { should contain_file(conf_file).without_content(%r{content_match: }) }
        it { should contain_file(conf_file).without_content(%r{reverse_content_match: true}) }
        it { should contain_file(conf_file).without_content(%r{include_content: true}) }
        it { should contain_file(conf_file).without_content(%r{collect_response_time: true}) }
        it { should contain_file(conf_file).without_content(%r{http_response_status_code: }) }
        it { should contain_file(conf_file).without_content(%r{disable_ssl_validation: false}) }
        it { should contain_file(conf_file).without_content(%r{skip_event: }) }
        it { should contain_file(conf_file).without_content(%r{no_proxy: }) }
        it { should contain_file(conf_file).without_content(%r{check_certificate_expiration: }) }
        it { should contain_file(conf_file).without_content(%r{days_warning: }) }
        it { should contain_file(conf_file).without_content(%r{days_critical: }) }
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
          method: 'post',
          data: 'key=value',
          threshold: 456,
          window: 789,
          content_match: 'foomatch',
          reverse_content_match: true,
          include_content: true,
          collect_response_time: false,
          disable_ssl_validation: true,
          skip_event: true,
          http_response_status_code: '503',
          no_proxy: true,
          check_certificate_expiration: true,
          days_warning: 14,
          days_critical: 7,
          allow_redirects: true,
          ca_certs: '/dev/null'
        }}

        it { should contain_file(conf_file).with_content(%r{name: foo.bar.baz}) }
        it { should contain_file(conf_file).with_content(%r{url: http://foo.bar.baz:4096}) }
        it { should contain_file(conf_file).with_content(%r{username: foouser}) }
        it { should contain_file(conf_file).with_content(%r{password: barpassword}) }
        it { should contain_file(conf_file).with_content(%r{timeout: 123}) }
        it { should contain_file(conf_file).with_content(%r{method: post}) }
        it { should contain_file(conf_file).with_content(%r{data: key=value}) }
        it { should contain_file(conf_file).with_content(%r{threshold: 456}) }
        it { should contain_file(conf_file).with_content(%r{window: 789}) }
        it { should contain_file(conf_file).with_content(%r{content_match: 'foomatch'}) }
        it { should contain_file(conf_file).with_content(%r{reverse_content_match: true}) }
        it { should contain_file(conf_file).with_content(%r{include_content: true}) }
        it { should contain_file(conf_file).without_content(%r{collect_response_time: true}) }
        it { should contain_file(conf_file).with_content(%r{disable_ssl_validation: true}) }
        it { should contain_file(conf_file).with_content(%r{skip_event: true}) }
        it { should contain_file(conf_file).with_content(%r{http_response_status_code: 503}) }
        it { should contain_file(conf_file).with_content(%r{no_proxy: true}) }
        it { should contain_file(conf_file).with_content(%r{check_certificate_expiration: true}) }
        it { should contain_file(conf_file).with_content(%r{days_warning: 14}) }
        it { should contain_file(conf_file).with_content(%r{days_critical: 7}) }
        it { should contain_file(conf_file).with_content(%r{allow_redirects: true}) }
        it { should contain_file(conf_file).with_content(%r{ca_certs: /dev/null}) }
      end

      context 'with json post data' do
        let(:params) {{
          sitename: 'foo.bar.baz',
          url: 'http://foo.bar.baz:4096',
          method: 'post',
          data: ['key: value'],
          headers: ['Content-Type: application/json'],
        }}
        it { should contain_file(conf_file).with_content(%r{method: post}) }
        it { should contain_file(conf_file).with_content(/data:\s+key:\s+value/) }
        it { should contain_file(conf_file).with_content(/headers:\s+Content-Type:\s+application\/json/) }
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
  end
end
