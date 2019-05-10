require 'spec_helper'

describe 'datadog_agent::integrations::activemq_xml' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{enabled}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if enabled
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if enabled
        let(:conf_file) { "#{conf_dir}/activemq_xml.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/activemq_xml.d/conf.yaml" }
      end

      context 'with default parameters' do
        it { should compile }
      end

      context 'with password set' do
        let(:params) {{
          username: 'foo',
          password: 'abc123',
        }}

        it { should compile.with_all_deps }
        it { should contain_file(conf_file).with(
          owner: dd_user,
          group: dd_group,
          mode: '0600',
        )}
        it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }
        it { should contain_file(conf_file).with_content(/username: foo/) }
        it { should contain_file(conf_file).with_content(/password: abc123/) }

        context 'with default parameters' do
          it {
            should contain_file(conf_file)
                .with_content(%r{http://localhost:8161})
                .with_content(%r{supress_errors: false})
                .without_content(%r{detailed_queues:})
                .without_content(%r{detailed_topics:})
                .without_content(%r{detailed_subscribers:})
          }
        end

        context 'with extra detailed parameters' do
          let(:params) {{
            supress_errors: true,
            detailed_queues: %w(queue1 queue2),
            detailed_topics: %w(topic1 topic2),
            detailed_subscribers: %w(subscriber1 subscriber2),
          }}
          it {
            should contain_file(conf_file)
              .with_content(%r{http://localhost:8161})
              .with_content(%r{supress_errors: true})
              .with_content(%r{detailed_queues:.*\s+- queue1\s+- queue2})
              .with_content(%r{detailed_topics:.*\s+- topic1\s+- topic2})
              .with_content(%r{detailed_subscribers:.*\s+- subscriber1\s+- subscriber2})
          }
        end

        context 'with instances set' do
          let(:params) {{
            instances: [
                {
                    'url'     => 'http://localhost:8161',
                    'username' => 'joe',
                    'password' => 'hunter1',
                    'detailed_queues' => %w(queue1 queue2),
                    'detailed_topics' => %w(topic1 topic2),
                    'detailed_subscribers' => %w(subscriber1 subscriber2),
                },
                {
                    'url'     => 'http://remotehost:8162',
                    'username' => 'moe',
                    'password' => 'hunter2',
                    'detailed_queues' => %w(queue3 queue4),
                    'detailed_topics' => %w(topic3 topic4),
                    'detailed_subscribers' => %w(subscriber3 subscriber4),
                },
            ],
          }}
          it {
            should contain_file(conf_file)
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
