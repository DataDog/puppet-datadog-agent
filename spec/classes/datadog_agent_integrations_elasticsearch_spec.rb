require 'spec_helper'

describe 'datadog_agent::integrations::elasticsearch' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/elastic.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/elastic.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_FILE,
      )}

      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{    - url: http://localhost:9200}) }
        it { should contain_file(conf_file).with_content(%r{      cluster_stats: false}) }
        it { should contain_file(conf_file).with_content(%r{      pending_task_stats: true}) }
        it { should contain_file(conf_file).with_content(%r{      pshard_stats: false}) }
        it { should_not contain_file(conf_file).with_content(%r{      username}) }
        it { should_not contain_file(conf_file).with_content(%r{      password}) }
        it { should_not contain_file(conf_file).with_content(%r{      ssl_verify}) }
        it { should_not contain_file(conf_file).with_content(%r{      ssl_cert}) }
        it { should_not contain_file(conf_file).with_content(%r{      ssl_key}) }
        it { should_not contain_file(conf_file).with_content(%r{      tags:}) }
      end

      context 'with parameters set' do
        let(:params) {{
          password:           'password',
          pending_task_stats: false,
          url:                'https://foo:4242',
          username:           'username',
          ssl_cert:           '/etc/ssl/certs/client.pem',
          ssl_key:            '/etc/ssl/private/client.key',
          tags:               ['tag1:key1'],
        }}
        it { should contain_file(conf_file).with_content(%r{    - url: https://foo:4242}) }
        it { should contain_file(conf_file).with_content(%r{      pending_task_stats: false}) }
        it { should contain_file(conf_file).with_content(%r{      username: username}) }
        it { should contain_file(conf_file).with_content(%r{      password: password}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_verify: true}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_cert: /etc/ssl/certs/client.pem}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_key: /etc/ssl/private/client.key}) }
        it { should contain_file(conf_file).with_content(%r{      tags:}) }
        it { should contain_file(conf_file).with_content(%r{        - tag1:key1}) }
      end

      context 'with multiple instances set' do
        let(:params) {
          {
            instances: [
              {
                'cluster_stats'      => true,
                'password'           => 'password',
                'pending_task_stats' => false,
                'pshard_stats'       => false,
                'url'                => 'https://foo:4242',
                'username'           => 'username',
                'ssl_verify'         => true,
                'ssl_cert'           => '/etc/ssl/certs/client.pem',
                'ssl_key'            => '/etc/ssl/private/client.key',
                'tags'               => ['tag1:key1'],
              },
              {
                'cluster_stats'      => true,
                'password'           => 'password_2',
                'pending_task_stats' => true,
                'pshard_stats'       => false,
                'url'                => 'https://bar:2424',
                'username'           => 'username_2',
                'ssl_verify'         => false,
                'ssl_cert'           => '/etc/ssl/certs/client.pem',
                'ssl_key'            => '/etc/ssl/private/client.key',
                'tags'               => ['tag2:key2'],
              }
            ]
          }
        }
        it { should contain_file(conf_file).with_content(%r{instances:}) }
        it { should contain_file(conf_file).with_content(%r{    - url: https://foo:4242}) }
        it { should contain_file(conf_file).with_content(%r{      cluster_stats: true}) }
        it { should contain_file(conf_file).with_content(%r{      pending_task_stats: false}) }
        it { should contain_file(conf_file).with_content(%r{      username: username}) }
        it { should contain_file(conf_file).with_content(%r{      password: password}) }
        it { should contain_file(conf_file).with_content(%r{      pshard_stats: false}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_verify: true}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_cert: /etc/ssl/certs/client.pem}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_key: /etc/ssl/private/client.key}) }
        it { should contain_file(conf_file).with_content(%r{      tags:}) }
        it { should contain_file(conf_file).with_content(%r{        - tag1:key1}) }
        it { should contain_file(conf_file).with_content(%r{    - url: https://bar:2424}) }
        it { should contain_file(conf_file).with_content(%r{      cluster_stats: true}) }
        it { should contain_file(conf_file).with_content(%r{      pending_task_stats: true}) }
        it { should contain_file(conf_file).with_content(%r{      username: username_2}) }
        it { should contain_file(conf_file).with_content(%r{      password: password_2}) }
        it { should contain_file(conf_file).with_content(%r{      pshard_stats: false}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_verify: false}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_cert: /etc/ssl/certs/client.pem}) }
        it { should contain_file(conf_file).with_content(%r{      ssl_key: /etc/ssl/private/client.key}) }
        it { should contain_file(conf_file).with_content(%r{      tags:}) }
        it { should contain_file(conf_file).with_content(%r{        - tag2:key2}) }
      end
    end
  end
end
