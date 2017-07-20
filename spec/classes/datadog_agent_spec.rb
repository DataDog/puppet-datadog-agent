require 'spec_helper'

describe 'datadog_agent' do
  context 'unsupported operating system' do
    describe 'datadog_agent class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          osfamily:         'Solaris',
          operatingsystem:  'Nexenta'
        }
      end

      it do
        expect {
          should contain_package('module')
        }.to raise_error(Puppet::Error, /Unsupported operatingsystem: Nexenta/)
      end
    end
  end

  # Test all supported OSes
  context 'all supported operating systems' do
    ALL_OS.each do |operatingsystem|
      describe "datadog_agent class common actions on #{operatingsystem}" do
        let(:params) { { puppet_run_reports: true, puppet_gem_provider: 'gem' } }
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: DEBIAN_OS.include?(operatingsystem) ? 'debian' : 'redhat'
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('datadog_agent') }

        describe 'datadog_agent imports the default params' do
          it { should contain_class('datadog_agent::params') }
        end

        it { should contain_file('/etc/dd-agent') }
        it { should contain_concat('/etc/dd-agent/datadog.conf') }
        it { should contain_file('/etc/dd-agent/conf.d').with_ensure('directory') }

        it { should contain_class('datadog_agent::reports') }

        describe 'parameter check' do
            context 'with defaults' do
                context 'for proxy' do
                    it { should contain_concat__fragment('datadog header').with(
                    'content' => /^dd_url: https:\/\/app.datadoghq.com\n/,
                    )}
                    it { should contain_concat__fragment('datadog header').with(
                    'content' => /^# proxy_host:\n/,
                    )}
                    it { should contain_concat__fragment('datadog header').with(
                    'content' => /^# proxy_port:\n/,
                    )}
                    it { should contain_concat__fragment('datadog header').with(
                    'content' => /^# proxy_user:\n/,
                    )}
                    it { should contain_concat__fragment('datadog header').with(
                    'content' => /^# proxy_password:\n/,
                    )}
                    it { should contain_concat__fragment('datadog header').with(
                    'content' => /^# skip_ssl_validation: no\n/,
                    )}
                end

                context 'for general' do
                    it { should contain_concat__fragment('datadog header').with(
                    'content' => /^api_key: your_API_key\n/,
                    )}
                    it { should contain_concat__fragment('datadog header').with(
                    'content' => /^# hostname:\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^non_local_traffic: false\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^collect_ec2_tags: false\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^collect_instance_metadata: true\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /# recent_point_threshold: 30\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# listen_port: 17123\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# graphite_listen_port: 17124\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# additional_checksd: \/etc\/dd-agent\/checks.d\/\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^use_curl_http_client: false\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# device_blacklist_re: .*\\\/dev\\\/mapper\\\/lxc-box.*\n/,
                    )}
                end

                context 'for pup' do
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^use_pup: no\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# pup_port: 17125\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# pup_interface: localhost\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# pup_url: http:\/\/localhost:17125\n/,
                    )}
                end

                context 'for dogstatsd' do
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# bind_host: localhost\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^use_dogstatsd: yes\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_port: 8125\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# dogstatsd_target: http:\/\/localhost:17123\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# dogstatsd_interval: 10\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_normalize: yes\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# statsd_forward_host: address_of_own_statsd_server\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# statsd_forward_port: 8125\n/,
                    )}
                end

                context 'for ganglia' do
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# ganglia_host: localhost\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# ganglia_port: 8651\n/,
                    )}
                end

                context 'for logging' do
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^log_level: INFO\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^log_to_syslog: yes\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# collector_log_file: \/var\/log\/datadog\/collector.log\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# forwarder_log_file: \/var\/log\/datadog\/forwarder.log\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# dogstatsd_log_file: \/var\/log\/datadog\/dogstatsd.log\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    #'content' => /^# pup_log_file:        \/var\/log\/datadog\/pup.log\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# syslog_host:\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^# syslog_port:\n/,
                    )}
                end

                context 'for service_discovery' do
                    it { should contain_concat__fragment('datadog footer').without(
                    'content' => /^service_discovery_backend:\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').without(
                    'content' => /^sd_config_backend:\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').without(
                    'content' => /^sd_backend_host:\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').without(
                    'content' => /^sd_backend_port:\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').without(
                    'content' => /^sd_template_dir:\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').without(
                    'content' => /^consul_token:\n/,
                    )}
                    it { should contain_concat__fragment('datadog footer').without(
                    'content' => /^# sd_jmx_enable:\n/,
                    )}
                end

                context 'for APM' do
                    it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^apm_enabled: false\n/,
                    )}
                end
            end

            context 'with user provided paramaters' do
            context 'with a custom dd_url' do
                let(:params) {{:dd_url => 'https://notaurl.datadoghq.com'}}
                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^dd_url: https:\/\/notaurl.datadoghq.com\n/,
                )}
            end
            context 'with a custom proxy_host' do
                let(:params) {{:proxy_host => 'localhost'}}
                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^proxy_host: localhost\n/,
                )}
            end
            context 'with a custom proxy_port' do
                let(:params) {{:proxy_port => '1234'}}
                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^proxy_port: 1234\n/,
                )}
            end
            context 'with a custom proxy_port, specified as an integer' do
                let(:params) {{:proxy_port => 1234}}
                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^proxy_port: 1234\n/,
                )}
            end
            context 'with a custom proxy_user' do
                let(:params) {{:proxy_user => 'notauser'}}
                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^proxy_user: notauser\n/,
                )}
            end
            context 'with a custom api_key' do
                let(:params) {{:api_key => 'notakey'}}
                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^api_key: notakey\n/,
                )}
            end
            context 'with a custom hostname' do
                let(:params) {{:host => 'notahost'}}

                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^hostname: notahost\n/,
                )}
            end
            context 'with non_local_traffic set to true' do
                let(:params) {{:non_local_traffic => true}}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^non_local_traffic: true\n/,
                )}
            end
            #Should expand testing to cover changes to the case upcase
            context 'with log level set to critical' do
                let(:params) {{:log_level => 'critical'}}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^log_level: CRITICAL\n/,
                )}
            end
            context 'with a custom hostname' do
                let(:params) {{:host => 'notahost'}}
                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^hostname: notahost\n/,
                )}
            end
            context 'with log_to_syslog set to false' do
                let(:params) {{:log_to_syslog => false}}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^log_to_syslog: no\n/,
                )}
            end
            context 'with skip_ssl_validation set to true' do
                let(:params) {{:skip_ssl_validation => true }}
                it { should contain_concat__fragment('datadog header').with(
                    'content' => /^skip_ssl_validation: true\n/,
                )}
            end
            context 'with collect_ec2_tags set to yes' do
                let(:params) {{:collect_ec2_tags => true }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^collect_ec2_tags: true\n/,
                )}
            end
            context 'with collect_instance_metadata set to no' do
                let(:params) {{:collect_instance_metadata => false }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^collect_instance_metadata: false\n/,
                )}
            end
            context 'with recent_point_threshold set to 60' do
                let(:params) {{:recent_point_threshold => '60' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^recent_point_threshold: 60\n/,
                )}
            end
            context 'with a custom port set to 17125' do
                let(:params) {{:listen_port => '17125' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^listen_port: 17125\n/,
                )}
            end
            context 'with a custom port set to 17125, specified as an integer' do
                let(:params) {{:listen_port => 17125 }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^listen_port: 17125\n/,
                )}
            end
            context 'listening for graphite data on port 17124' do
                let(:params) {{:graphite_listen_port => '17124' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^graphite_listen_port: 17124\n/,
                )}
            end
            context 'listening for graphite data on port 17124, port specified as an integer' do
                let(:params) {{:graphite_listen_port => 17124 }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^graphite_listen_port: 17124\n/,
                )}
            end
            context 'with configuration for a custom checks.d' do
                let(:params) {{:additional_checksd => '/etc/dd-agent/checks_custom.d' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^additional_checksd: \/etc\/dd-agent\/checks_custom.d\n/,
                )}
            end
            context 'with configuration for a custom checks.d' do
                let(:params) {{:additional_checksd => '/etc/dd-agent/checks_custom.d' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^additional_checksd: \/etc\/dd-agent\/checks_custom.d\n/,
                )}
            end
            context 'with configuration for a custom checks.d' do
                let(:params) {{:additional_checksd => '/etc/dd-agent/checks_custom.d' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^additional_checksd: \/etc\/dd-agent\/checks_custom.d\n/,
                )}
            end
            context 'with using the Tornado HTTP client' do
                let(:params) {{:use_curl_http_client => true }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^use_curl_http_client: true\n/,
                )}
            end
            context 'with a custom bind_host' do
                let(:params) {{:bind_host => 'test'  }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^bind_host: test\n/,
                )}
            end
            context 'with pup enabled' do
                let(:params) {{:use_pup => true }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^use_pup: yes\n/,
                )}
            end
            context 'with a custom pup_port' do
                let(:params) {{:pup_port => '17126' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^pup_port: 17126\n/,
                )}
            end
            context 'with a custom pup_port, specified as an integer' do
                let(:params) {{:pup_port => 17126 }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^pup_port: 17126\n/,
                )}
            end
            context 'with a custom pup_interface' do
                let(:params) {{:pup_interface => 'notalocalhost' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^pup_interface: notalocalhost\n/,
                )}
            end
            context 'with a custom pup_url' do
                let(:params) {{:pup_url => 'http://localhost:17126' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^pup_url: http:\/\/localhost:17126\n/,
                )}
            end
            context 'with use_dogstatsd set to no' do
                let(:params) {{:use_dogstatsd => false}}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^use_dogstatsd: no\n/,
                )}
            end
            context 'with use_dogstatsd set to yes' do
                let(:params) {{:use_dogstatsd => true}}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^use_dogstatsd: yes\n/,
                )}
            end
            context 'with dogstatsd_port set to 8126 - must be specified as an integer!' do
                let(:params) {{:dogstatsd_port => 8126 }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_port: 8126\n/,
                )}
            end
            context 'with dogstatsd_port set to 8126' do
                let(:params) {{:dogstatsd_port  => 8126}}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_port: 8126\n/,
                )}
            end
            context 'with dogstatsd_target set to localhost:17124' do
                let(:params) {{:dogstatsd_target  => 'http://localhost:17124'}}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_target: http:\/\/localhost:17124\n/,
                )}
            end
            context 'with dogstatsd_interval set to 5' do
                let(:params) {{:dogstatsd_interval  => '5' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_interval: 5\n/,
                )}
            end
            context 'with dogstatsd_interval set to 5' do
                let(:params) {{:dogstatsd_interval  => '5' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_interval: 5\n/,
                )}
            end
            context 'with dogstatsd_normalize set to false' do
                let(:params) {{:dogstatsd_normalize  => false }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_normalize: no\n/,
                )}
            end
            context 'with statsd_forward_host set to localhost:3958' do
                let(:params) {{:statsd_forward_host  => 'localhost:3958' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^statsd_forward_host: localhost:3958\n/,
                )}
            end
            context 'with statsd_forward_port set to 8126' do
                let(:params) {{:statsd_forward_port => '8126' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^statsd_forward_port: 8126\n/,
                )}
            end
            context 'with statsd_forward_port set to 8126, specified as an integer' do
                let(:params) {{:statsd_forward_port => 8126 }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^statsd_forward_port: 8126\n/,
                )}
            end
            context 'with device_blacklist_re set to test' do
                let(:params) {{:device_blacklist_re  => 'test' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^device_blacklist_re: test\n/,
                )}
            end
            context 'with device_blacklist_re set to test' do
                let(:params) {{:device_blacklist_re  => 'test' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^device_blacklist_re: test\n/,
                )}
            end
            context 'with ganglia_host set to localhost and ganglia_port set to 12345' do
                let(:params) {{:ganglia_host => 'testhost', :ganglia_port => '12345' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^ganglia_port: 12345\n/,
                )}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^ganglia_host: testhost\n/,
                )}
            end
            context 'with ganglia_host set to localhost and ganglia_port set to 12345, port specified as an integer' do
                let(:params) {{:ganglia_host => 'testhost', :ganglia_port => 12345 }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^ganglia_port: 12345\n/,
                )}
            end
            context 'with dogstreams set to /path/to/log1:/path/to/parser' do
                let(:params) {{:dogstreams  => ['/path/to/log1:/path/to/parser'] }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstreams: \/path\/to\/log1:\/path\/to\/parser\n/,
                )}
            end
            context 'with custom_emitters set to /test/emitter' do
                let(:params) {{:custom_emitters  => '/test/emitter/' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^custom_emitters: \/test\/emitter\/\n/,
                )}
            end
            context 'with custom_emitters set to /test/emitter' do
                let(:params) {{:custom_emitters  => '/test/emitter/' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^custom_emitters: \/test\/emitter\/\n/,
                )}
            end
            context 'with collector_log_file set to /test/log' do
                let(:params) {{:collector_log_file  => '/test/log' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^collector_log_file: \/test\/log\n/,
                )}
            end
            context 'with forwarder_log_file set to /test/log' do
                let(:params) {{:forwarder_log_file  => '/test/log' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^forwarder_log_file: \/test\/log\n/,
                )}
            end
            context 'with forwarder_log_file set to /test/log' do
                let(:params) {{:forwarder_log_file  => '/test/log' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^forwarder_log_file: \/test\/log\n/,
                )}
            end
            context 'with dogstatsd_log_file set to /test/log' do
                let(:params) {{:dogstatsd_log_file  => '/test/log' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^dogstatsd_log_file: \/test\/log\n/,
                )}
            end
            context 'with pup_log_file set to /test/log' do
                let(:params) {{:pup_log_file  => '/test/log' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^pup_log_file: \/test\/log\n/,
                )}
            end
            context 'with syslog location set to localhost' do
                let(:params) {{:syslog_host  => 'localhost' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^syslog_host: localhost\n/,
                )}
            end
            context 'with syslog port set to 8080' do
                let(:params) {{:syslog_port => '8080' }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^syslog_port: 8080\n/,
                )}
            end
            context 'with syslog port set to 8080, specified as an integer' do
                let(:params) {{:syslog_port => 8080 }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^syslog_port: 8080\n/,
                )}
            end
            context 'with apm_enabled set to true' do
                let(:params) {{:apm_enabled  => true }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^apm_enabled: true\n/,
                )}
            end
            context 'with apm_enabled set to true and env specified' do
                let(:params) {
                    {:apm_enabled  => true,
                     :apm_env => 'foo',
                }}
                it { should contain_concat__fragment('datadog footer').with(
                    'content' => /^apm_enabled: true\n/,
                )}
                it { should contain_concat__fragment('datadog apm footer').with(
                    'content' => /^\[trace.agent\]\n/,
                )}
                it { should contain_concat__fragment('datadog apm footer').with(
                    'content' => /^env: foo\n/,
                )}
                it { should contain_concat__fragment('datadog apm footer').with(
                    'order' => '06',
                )}
            end
            context 'with service_discovery enabled' do
                let(:params) {
                    {:service_discovery_backend  => 'docker',
                     :sd_config_backend          => 'etcd',
                     :sd_backend_host            => 'localhost',
                     :sd_backend_port            => '8080',
                     :sd_jmx_enable              =>  true,
                }}
                it { should contain_concat__fragment('datadog footer').with(
                'content' => /^service_discovery_backend: docker\n/,
                )}
                it { should contain_concat__fragment('datadog footer').with(
                'content' => /^sd_config_backend: etcd\n/,
                )}
                it { should contain_concat__fragment('datadog footer').with(
                'content' => /^sd_backend_host: localhost\n/,
                )}
                it { should contain_concat__fragment('datadog footer').with(
                'content' => /^sd_backend_port: 8080\n/,
                )}
                it { should contain_concat__fragment('datadog footer').with(
                'content' => /^sd_jmx_enable: true\n/,
                )}
            end
            context 'with extra_template enabled' do
                let(:params) {
                    {:extra_template => 'custom_datadog/extra_template_test.erb',
                }}
                it { should contain_concat__fragment('datadog extra_template footer').with(
                'order' => '06',
                )}
                it { should contain_concat__fragment('datadog extra_template footer').with(
                'content' => /^# extra template is here\n/,
                )}
                it { should contain_concat__fragment('datadog apm footer').with(
                'order' => '07',
                )}
            end
            end
        end

        if DEBIAN_OS.include?(operatingsystem)
          it { should contain_class('datadog_agent::ubuntu') }
        elsif REDHAT_OS.include?(operatingsystem)
          it { should contain_class('datadog_agent::redhat') }
        end
      end
    end
  end

  context "with facts to tags set" do
    describe "ensure facts_array outputs a list of tags" do
      let(:params) { { puppet_run_reports: true, puppet_gem_provider: 'gem', facts_to_tags: ['osfamily', 'facts_array']} }
      let(:facts) do
        {
            operatingsystem: 'CentOS',
            osfamily: 'redhat',
            facts_array: ['one', 'two', 'three']
        }

        it { should contain_concat('/etc/dd-agent/datadog.conf') }
        it { should contain_concat__fragment('datadog tags').with(/tags: osfamily:redhat, facts_array:one, facts_array:two, facts_array:three/) }
      end
    end
  end
end
