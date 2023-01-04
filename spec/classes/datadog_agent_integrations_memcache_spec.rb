require 'spec_helper'

describe 'datadog_agent::integrations::memcache' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/mcache.yaml'
                  else
                    "#{CONF_DIR}/mcache.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{url: localhost}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags:}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            url: 'foobar',
            port: '11212',
            items: 'true',
            slabs: 'true',
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{url: foobar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 11212}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{items: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{slabs: true}) }
      end

      context 'with tags parameter single value' do
        let(:params) do
          {
            tags: 'foo',
          }
        end

        it { is_expected.not_to compile }

        skip 'this is currently unimplemented behavior' do
          it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s*?[^-]}m) }
        end
      end

      context 'with tags parameter array' do
        let(:params) do
          {
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar\s+- baz\s*?[^-]}m) }
      end

      context 'with tags parameter empty values' do
        context 'mixed in with other tags' do
          let(:params) do
            {
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

      context 'with multiple instances set' do
        let(:params) do
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
                'port'  => '22122',
                'items' => false,
                'slabs' => false,
                'tags'  => ['tag2:value2'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{instances:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{  - url: localhost}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    port: 11211}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    items: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    slabs: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    tags:\n      - tag1:value1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{  - url: foo.bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    port: 22122}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    items: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    slabs: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    tags:\n      - tag2:value2}) }
      end
    end
  end
end
