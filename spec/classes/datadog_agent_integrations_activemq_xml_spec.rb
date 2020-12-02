require 'spec_helper'

describe 'datadog_agent::integrations::activemq_xml' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/activemq_xml.yaml'
                  else
                    "#{CONF_DIR}/activemq_xml.d/conf.yaml"
                  end

      context 'with default parameters' do
        it { is_expected.to compile }
      end

      context 'with password set' do
        let(:params) do
          {
            username: 'foo',
            password: 'abc123',
          }
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
        it { is_expected.to contain_file(conf_file).with_content(%r{username: foo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: abc123}) }

        context 'with default parameters' do
          it {
            is_expected.to contain_file(conf_file)
              .with_content(%r{http://localhost:8161})
              .with_content(%r{supress_errors: false})
              .without_content(%r{detailed_queues:})
              .without_content(%r{detailed_topics:})
              .without_content(%r{detailed_subscribers:})
          }
        end

        context 'with extra detailed parameters' do
          let(:params) do
            {
              supress_errors: true,
              detailed_queues: ['queue1', 'queue2'],
              detailed_topics: ['topic1', 'topic2'],
              detailed_subscribers: ['subscriber1', 'subscriber2'],
            }
          end

          it {
            is_expected.to contain_file(conf_file)
              .with_content(%r{http://localhost:8161})
              .with_content(%r{supress_errors: true})
              .with_content(%r{detailed_queues:.*\s+- queue1\s+- queue2})
              .with_content(%r{detailed_topics:.*\s+- topic1\s+- topic2})
              .with_content(%r{detailed_subscribers:.*\s+- subscriber1\s+- subscriber2})
          }
        end

        context 'with instances set' do
          let(:params) do
            {
              instances: [
                {
                  'url' => 'http://localhost:8161',
                  'username' => 'joe',
                  'password' => 'hunter1',
                  'detailed_queues' => ['queue1', 'queue2'],
                  'detailed_topics' => ['topic1', 'topic2'],
                  'detailed_subscribers' => ['subscriber1', 'subscriber2'],
                },
                {
                  'url' => 'http://remotehost:8162',
                  'username' => 'moe',
                  'password' => 'hunter2',
                  'detailed_queues' => ['queue3', 'queue4'],
                  'detailed_topics' => ['topic3', 'topic4'],
                  'detailed_subscribers' => ['subscriber3', 'subscriber4'],
                },
              ],
            }
          end

          it {
            is_expected.to contain_file(conf_file)
              .with_content(%r{url: http://localhost:8161})
              .without_content(%r{supress_errors:})
              .with_content(%r{username: joe})
              .with_content(%r{password: hunter1})
              .with_content(%r{detailed_queues:.*\s+- queue1\s+- queue2})
              .with_content(%r{detailed_topics:.*\s+- topic1\s+- topic2})
              .with_content(%r{detailed_subscribers:.*\s+- subscriber1\s+- subscriber2})
              .with_content(%r{url: http://remotehost:8162})
              .without_content(%r{supress_errors:})
              .with_content(%r{username: moe})
              .with_content(%r{password: hunter2})
              .with_content(%r{detailed_queues:.*\s+- queue3\s+- queue4})
              .with_content(%r{detailed_topics:.*\s+- topic3\s+- topic4})
              .with_content(%r{detailed_subscribers:.*\s+- subscriber3\s+- subscriber4})
          }
        end
      end
    end
  end
end
