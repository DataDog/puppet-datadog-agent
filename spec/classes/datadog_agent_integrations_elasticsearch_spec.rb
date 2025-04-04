require 'spec_helper'

describe 'datadog_agent::integrations::elasticsearch' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = "#{CONF_DIR}/elastic.d/conf.yaml"

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_FILE,
        )
      }

      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).with_content(%r{    - url: http://localhost:9200}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      cluster_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      index_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pending_task_stats: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pshard_stats: false}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      username}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      password}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      tls_verify}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      tls_cert}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      tls_ca_cert}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      tls_private_key}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      tls_use_host_header}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      tls_ignore_warning}) }
        it { is_expected.not_to contain_file(conf_file).with_content(%r{      tags:}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            password:           'password',
            pending_task_stats: false,
            url:                'https://foo:4242',
            username:           'username',
            tls_cert:           '/etc/ssl/certs/client.pem',
            tls_ca_cert:        '/etc/ssl/certs/ca.pem',
            tls_private_key:    '/etc/ssl/private/client.key',
            tls_use_host_header: true,
            tls_ignore_warning:  true,
            tls_protocols_allowed: ['TLSv1.2', 'TLSv1.3'],
            tls_ciphers:           ['TLS_AES_256_GCM_SHA384', 'TLS_CHACHA20_POLY1305_SHA256'],
            tags:                  ['tag1:key1'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{    - url: https://foo:4242}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pending_task_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      username: username}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      password: password}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tags:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - tag1:key1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_verify: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_cert: /etc/ssl/certs/client.pem}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_ca_cert: /etc/ssl/certs/ca.pem}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_private_key: /etc/ssl/private/client.key}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_use_host_header: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_ignore_warning: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_protocols_allowed:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - TLSv1.2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - TLSv1.3}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_ciphers:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - TLS_AES_256_GCM_SHA384}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - TLS_CHACHA20_POLY1305_SHA256}) }
      end

      context 'with multiple instances set' do
        let(:params) do
          {
            instances: [
              {
                'cluster_stats'      => true,
                'index_stats'        => false,
                'password'           => 'password',
                'pending_task_stats' => false,
                'pshard_stats'       => true,
                'url'                => 'https://foo:4242',
                'username'           => 'username',
                'tls_verify'         => true,
                'tls_cert'           => '/etc/ssl/certs/client.pem',
                'tls_private_key'    => '/etc/ssl/private/client.key',
                'tags'               => ['tag1:key1'],
              },
              {
                'cluster_stats'      => false,
                'index_stats'        => true,
                'password'           => 'password_2',
                'pending_task_stats' => true,
                'pshard_stats'       => false,
                'url'                => 'https://bar:2424',
                'username'           => 'username_2',
                'tls_verify'         => false,
                'tags'               => ['tag2:key2'],
                'tls_use_host_header' => true,
                'tls_ignore_warning'  => true,
                'tls_protocols_allowed' => ['TLSv1.2', 'TLSv1.3'],
                'tls_ciphers'           => ['TLS_AES_256_GCM_SHA384', 'TLS_CHACHA20_POLY1305_SHA256'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{instances:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    - url: https://foo:4242}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      cluster_stats: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      index_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pending_task_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      username: username}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      password: password}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pshard_stats: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_verify: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_cert: /etc/ssl/certs/client.pem}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_private_key: /etc/ssl/private/client.key}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tags:\n        - tag1:key1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    - url: https://bar:2424}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      cluster_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      index_stats: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pending_task_stats: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      username: username_2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      password: password_2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pshard_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_verify: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tags:\n        - tag2:key2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_use_host_header: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_ignore_warning: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_protocols_allowed:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - TLSv1.2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - TLSv1.3}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_ciphers:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - TLS_AES_256_GCM_SHA384}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{        - TLS_CHACHA20_POLY1305_SHA256}) }
      end

      context 'with legacy ssl_verify parameter set' do
        let(:params) do
          {
            password:    'password',
            url:         'https://foo:4242',
            username:    'username',
            ssl_verify:  true,
            tls_cert:    '/etc/ssl/certs/client.pem',
            tls_ca_cert: '/etc/ssl/certs/ca.pem',
            tls_private_key: '/etc/ssl/private/client.key',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{instances:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    - url: https://foo:4242}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      cluster_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      index_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pending_task_stats: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      pshard_stats: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_verify: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_cert: /etc/ssl/certs/client.pem}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      tls_private_key: /etc/ssl/private/client.key}) }
      end
    end
  end
end
