require 'spec_helper'

describe 'datadog_agent::integrations::http_check' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/http_check.yaml'
                  else
                    "#{CONF_DIR}/http_check.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).without_content(%r{name: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{url: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{username: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{password: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{timeout: 1}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{data: }) }
        it { is_expected.to contain_file(conf_file).without_content(%(threshold: )) }
        it { is_expected.to contain_file(conf_file).without_content(%r{window: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{content_match: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{reverse_content_match: true}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{include_content: true}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{collect_response_time: true}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{http_response_status_code: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{disable_ssl_validation: false}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{skip_event: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{no_proxy: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{check_certificate_expiration: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{days_warning: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{days_critical: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{headers: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags: }) }
      end

      context 'with parameters set' do
        let(:params) do
          {
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
            ca_certs: '/dev/null',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{name: foo.bar.baz}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://foo.bar.baz:4096}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{username: foouser}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: barpassword}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 123}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{method: post}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{data: key=value}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{threshold: 456}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{window: 789}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{content_match: 'foomatch'}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{reverse_content_match: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{include_content: true}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{collect_response_time: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{disable_ssl_validation: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{skip_event: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{http_response_status_code: 503}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{no_proxy: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{check_certificate_expiration: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{days_warning: 14}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{days_critical: 7}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{allow_redirects: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ca_certs: /dev/null}) }
      end

      context 'with json post data' do
        let(:params) do
          {
            sitename: 'foo.bar.baz',
            url: 'http://foo.bar.baz:4096',
            method: 'post',
            data: ['key: value'],
            headers: ['Content-Type: application/json'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{method: post}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{data:\s+key:\s+value}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{headers:\s+Content-Type:\s+application/json}) }
      end

      context 'with headers parameter array' do
        let(:params) do
          {
            sitename: 'foo.bar.baz',
            url: 'http://foo.bar.baz:4096',
            headers: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{headers:\s+foo\s+bar\s+baz\s*?[^-]}m) }
      end

      context 'with headers parameter empty values' do
        context 'mixed in with other headers' do
          let(:params) do
            {
              sitename: 'foo.bar.baz',
              url: 'http://foo.bar.baz:4096',
              headers: ['foo', '', 'baz'],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{headers:\s+foo\s+baz\s*?[^-]}m) }
        end

        context 'single element array of an empty string' do
          let(:params) do
            {
              headers: [''],
            }
          end

          skip('undefined behavior')
        end

        context 'single value empty string' do
          let(:params) do
            {
              headers: '',
            }
          end

          skip('doubly undefined behavior')
        end
      end

      context 'with tags parameter array' do
        let(:params) do
          {
            sitename: 'foo.bar.baz',
            url: 'http://foo.bar.baz:4096',
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar\s+- baz\s*?[^-]}m) }
      end

      context 'with tags parameter empty values' do
        context 'mixed in with other tags' do
          let(:params) do
            {
              sitename: 'foo.bar.baz',
              url: 'http://foo.bar.baz:4096',
              tags: ['foo', '', 'baz'],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- baz\s*?[^-]}m) }
        end

        context 'single element array of an empty string' do
          let(:params) do
            {
              tags: [''],
            }
          end

          skip('undefined behavior')
        end

        context 'single value empty string' do
          let(:params) do
            {
              tags: '',
            }
          end

          skip('doubly undefined behavior')
        end
      end

      context 'with contact set' do
        let(:params) do
          {
            contact: %r{alice bob carlo},
          }
        end

        # the parameter is '$contact' and the template uses '@contacts', so neither is used
        skip 'this functionality appears to not be functional' do
          it { is_expected.to contain_file(conf_file).with_content(%r{notify:\s+- alice\s+bob\s+carlo}) }
        end
      end
    end
  end
end
