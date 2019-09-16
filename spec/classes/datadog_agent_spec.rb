require 'spec_helper'

describe 'datadog_agent' do

  if !RSpec::Support::OS.windows?
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
  end

  # Test all supported OSes
  context 'all supported operating systems' do
    ALL_OS.each do |operatingsystem|
      describe "datadog_agent 5 class common actions on #{operatingsystem}" do
        let(:params) { { puppet_run_reports: true,
                         agent5_enable: true,
        } }
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: getosfamily(operatingsystem),
          }
        end

        if WINDOWS_OS.include?(operatingsystem)
          it "agent 5 should raise on Windows" do
            should raise_error(Puppet::Error, /Installation of agent 5 with puppet is not supported on Windows/)
          end
        else
          it { should compile.with_all_deps }

          it { should contain_class('datadog_agent') }

          describe 'datadog_agent imports the default params' do
            it { should contain_class('datadog_agent::params') }
          end

          it { should contain_file('/etc/datadog-agent') }
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
                  let(:params) {{ :dd_url => 'https://notaurl.datadoghq.com',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^dd_url: https:\/\/notaurl.datadoghq.com\n/,
                  )}
              end
              context 'with a custom proxy_host' do
                  let(:params) {{ :proxy_host => 'localhost',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^proxy_host: localhost\n/,
                  )}
              end
              context 'with a custom proxy_port' do
                  let(:params) {{ :proxy_port => '1234',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^proxy_port: 1234\n/,
                  )}
              end
              context 'with a custom proxy_port, specified as an integer' do
                  let(:params) {{ :proxy_port => 1234,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^proxy_port: 1234\n/,
                  )}
              end
              context 'with a custom proxy_user' do
                  let(:params) {{ :proxy_user => 'notauser',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^proxy_user: notauser\n/,
                  )}
              end
              context 'with a custom api_key' do
                  let(:params) {{ :api_key => 'notakey',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^api_key: notakey\n/,
                  )}
              end
              context 'with a custom hostname' do
                  let(:params) {{ :host => 'notahost',
                                  :agent5_enable => true,
                  }}

                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^hostname: notahost\n/,
                  )}
              end
              context 'with non_local_traffic set to true' do
                  let(:params) {{ :non_local_traffic => true,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^non_local_traffic: true\n/,
                  )}
              end
              #Should expand testing to cover changes to the case upcase
              context 'with log level set to critical' do
                  let(:params) {{ :log_level => 'critical',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^log_level: CRITICAL\n/,
                  )}
              end
              context 'with a custom hostname' do
                  let(:params) {{ :host => 'notahost',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^hostname: notahost\n/,
                  )}
              end
              context 'with log_to_syslog set to false' do
                  let(:params) {{ :log_to_syslog => false,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^log_to_syslog: no\n/,
                  )}
              end
              context 'with skip_ssl_validation set to true' do
                  let(:params) {{ :skip_ssl_validation => true,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog header').with(
                      'content' => /^skip_ssl_validation: true\n/,
                  )}
              end
              context 'with collect_ec2_tags set to yes' do
                  let(:params) {{ :collect_ec2_tags => true,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^collect_ec2_tags: true\n/,
                  )}
              end
              context 'with collect_instance_metadata set to no' do
                  let(:params) {{ :collect_instance_metadata => false,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^collect_instance_metadata: false\n/,
                  )}
              end
              context 'with recent_point_threshold set to 60' do
                  let(:params) {{ :recent_point_threshold => '60',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^recent_point_threshold: 60\n/,
                  )}
              end
              context 'with a custom port set to 17125' do
                  let(:params) {{ :listen_port => '17125',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^listen_port: 17125\n/,
                  )}
              end
              context 'with a custom port set to 17125, specified as an integer' do
                  let(:params) {{ :listen_port => 17125,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^listen_port: 17125\n/,
                  )}
              end
              context 'listening for graphite data on port 17124' do
                  let(:params) {{ :graphite_listen_port => '17124',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^graphite_listen_port: 17124\n/,
                  )}
              end
              context 'listening for graphite data on port 17124, port specified as an integer' do
                  let(:params) {{ :graphite_listen_port => 17124,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^graphite_listen_port: 17124\n/,
                  )}
              end
              context 'with configuration for a custom checks.d' do
                  let(:params) {{ :additional_checksd => '/etc/dd-agent/checks_custom.d',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^additional_checksd: \/etc\/dd-agent\/checks_custom.d\n/,
                  )}
              end
              context 'with configuration for a custom checks.d' do
                  let(:params) {{ :additional_checksd => '/etc/dd-agent/checks_custom.d',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^additional_checksd: \/etc\/dd-agent\/checks_custom.d\n/,
                  )}
              end
              context 'with configuration for a custom checks.d' do
                  let(:params) {{ :additional_checksd => '/etc/dd-agent/checks_custom.d',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^additional_checksd: \/etc\/dd-agent\/checks_custom.d\n/,
                  )}
              end
              context 'with using the Tornado HTTP client' do
                  let(:params) {{ :use_curl_http_client => true,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^use_curl_http_client: true\n/,
                  )}
              end
              context 'with a custom bind_host' do
                  let(:params) {{ :bind_host => 'test',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^bind_host: test\n/,
                  )}
              end
              context 'with pup enabled' do
                  let(:params) {{ :use_pup => true,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^use_pup: yes\n/,
                  )}
              end
              context 'with a custom pup_port' do
                  let(:params) {{ :pup_port => '17126',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^pup_port: 17126\n/,
                  )}
              end
              context 'with a custom pup_port, specified as an integer' do
                  let(:params) {{ :pup_port => 17126,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^pup_port: 17126\n/,
                  )}
              end
              context 'with a custom pup_interface' do
                  let(:params) {{ :pup_interface => 'notalocalhost',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^pup_interface: notalocalhost\n/,
                  )}
              end
              context 'with a custom pup_url' do
                  let(:params) {{ :pup_url => 'http://localhost:17126',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^pup_url: http:\/\/localhost:17126\n/,
                  )}
              end
              context 'with use_dogstatsd set to no' do
                  let(:params) {{ :use_dogstatsd => false,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^use_dogstatsd: no\n/,
                  )}
              end
              context 'with use_dogstatsd set to yes' do
                  let(:params) {{ :use_dogstatsd => true,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^use_dogstatsd: yes\n/,
                  )}
              end
              context 'with dogstatsd_port set to 8126 - must be specified as an integer!' do
                  let(:params) {{ :dogstatsd_port => 8126,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^dogstatsd_port: 8126\n/,
                  )}
              end
              context 'with dogstatsd_port set to 8126' do
                  let(:params) {{ :dogstatsd_port  => 8126,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^dogstatsd_port: 8126\n/,
                  )}
              end
              context 'with dogstatsd_target set to localhost:17124' do
                  let(:params) {{ :dogstatsd_target  => 'http://localhost:17124',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^dogstatsd_target: http:\/\/localhost:17124\n/,
                  )}
              end
              context 'with dogstatsd_interval set to 5' do
                  let(:params) {{ :dogstatsd_interval  => '5',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^dogstatsd_interval: 5\n/,
                  )}
              end
              context 'with dogstatsd_interval set to 5' do
                  let(:params) {{ :dogstatsd_interval  => '5',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^dogstatsd_interval: 5\n/,
                  )}
              end
              context 'with dogstatsd_normalize set to false' do
                  let(:params) {{ :dogstatsd_normalize  => false,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^dogstatsd_normalize: no\n/,
                  )}
              end
              context 'with statsd_forward_host set to localhost:3958' do
                  let(:params) {{ :statsd_forward_host  => 'localhost:3958',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^statsd_forward_host: localhost:3958\n/,
                  )}
              end
              context 'with statsd_forward_port set to 8126' do
                  let(:params) {{ :statsd_forward_port => '8126',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^statsd_forward_port: 8126\n/,
                  )}
              end
              context 'with statsd_forward_port set to 8126, specified as an integer' do
                  let(:params) {{ :statsd_forward_port => 8126,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^statsd_forward_port: 8126\n/,
                  )}
              end
              context 'with device_blacklist_re set to test' do
                  let(:params) {{ :device_blacklist_re  => 'test',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^device_blacklist_re: test\n/,
                  )}
              end
              context 'with device_blacklist_re set to test' do
                  let(:params) {{ :device_blacklist_re  => 'test',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^device_blacklist_re: test\n/,
                  )}
              end
              context 'with ganglia_host set to localhost and ganglia_port set to 12345' do
                  let(:params) {{ :ganglia_host => 'testhost',
                                  :ganglia_port => '12345',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^ganglia_port: 12345\n/,
                  )}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^ganglia_host: testhost\n/,
                  )}
              end
              context 'with ganglia_host set to localhost and ganglia_port set to 12345, port specified as an integer' do
                  let(:params) {{ :ganglia_host => 'testhost',
                                  :ganglia_port => 12345,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^ganglia_port: 12345\n/,
                  )}
              end
              context 'with dogstreams set to /path/to/log1:/path/to/parser' do
                  let(:params) {{ :dogstreams  => ['/path/to/log1:/path/to/parser'],
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^dogstreams: \/path\/to\/log1:\/path\/to\/parser\n/,
                  )}
              end
              context 'with custom_emitters set to /test/emitter' do
                  let(:params) {{ :custom_emitters  => '/test/emitter/',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^custom_emitters: \/test\/emitter\/\n/,
                  )}
              end
              context 'with custom_emitters set to /test/emitter' do
                  let(:params) {{ :custom_emitters  => '/test/emitter/',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^custom_emitters: \/test\/emitter\/\n/,
                  )}
              end
              context 'with collector_log_file set to /test/log' do
                  let(:params) {{ :collector_log_file  => '/test/log',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^collector_log_file: \/test\/log\n/,
                  )}
              end
              context 'with forwarder_log_file set to /test/log' do
                  let(:params) {{ :forwarder_log_file  => '/test/log',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^forwarder_log_file: \/test\/log\n/,
                  )}
              end
              context 'with forwarder_log_file set to /test/log' do
                  let(:params) {{ :forwarder_log_file  => '/test/log',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^forwarder_log_file: \/test\/log\n/,
                  )}
              end
              context 'with dogstatsd_log_file set to /test/log' do
                  let(:params) {{ :dogstatsd_log_file  => '/test/log',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^dogstatsd_log_file: \/test\/log\n/,
                  )}
              end
              context 'with pup_log_file set to /test/log' do
                  let(:params) {{ :pup_log_file  => '/test/log',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^pup_log_file: \/test\/log\n/,
                  )}
              end
              context 'with syslog location set to localhost' do
                  let(:params) {{ :syslog_host  => 'localhost',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^syslog_host: localhost\n/,
                  )}
              end
              context 'with syslog port set to 8080' do
                  let(:params) {{ :syslog_port => '8080',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^syslog_port: 8080\n/,
                  )}
              end
              context 'with syslog port set to 8080, specified as an integer' do
                  let(:params) {{ :syslog_port => 8080,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^syslog_port: 8080\n/,
                  )}
              end
              context 'with apm_enabled set to true' do
                  let(:params) {{ :apm_enabled  => true,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^apm_enabled: true\n/,
                  )}
              end
              context 'with apm_enabled set to true and env specified' do
                  let(:params) {{ :apm_enabled  => true,
                                  :apm_env => 'foo',
                                  :agent5_enable => true,
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
                      'order' => '07',
                  )}
              end
              context 'with apm_enabled and apm_analyzed_spans set' do
                  let(:params) {{ :apm_enabled  => true,
                                  :agent5_enable => true,
                                  :apm_analyzed_spans => {
                                      'foo|bar' => 0.5,
                                      'haz|qux' => 0.1
                                  },
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                      'content' => /^apm_enabled: true\n/,
                  )}
                  it { should contain_concat__fragment('datadog apm footer').with(
                      'content' => /^\[trace.analyzed_spans\]\n/,
                  )}
                  it { should contain_concat__fragment('datadog apm footer').with(
                      'content' => /^\[trace.analyzed_spans\]\nfoo|bar: 0.5\nhaz|qux: 0.1/,
                  )}
                  it { should contain_concat__fragment('datadog apm footer').with(
                      'order' => '07',
                  )}
              end
              context 'with service_discovery enabled' do
                  let(:params) {{ :service_discovery_backend  => 'docker',
                                  :sd_config_backend          => 'etcd',
                                  :sd_backend_host            => 'localhost',
                                  :sd_backend_port            => '8080',
                                  :sd_jmx_enable              =>  true,
                                  :agent5_enable => true,
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
                  let(:params) {{ :extra_template => 'custom_datadog/extra_template_test.erb',
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog extra_template footer').with(
                  'order' => '06',
                  )}
                  it { should contain_concat__fragment('datadog extra_template footer').with(
                  'content' => /^# extra template is here\n/,
                  )}
                  it { should_not contain_concat__fragment('datadog apm footer').with(
                  'order' => '07',
                  )}
              end
              context 'with APM enabled' do
                  let(:params) {{
                      :apm_enabled => true,
                      :apm_env => 'foo',
                      :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog apm footer').with(
                  'order' => '07',
                  )}
              end
              context 'with APM enabled but no APM env' do
                  let(:params) {{
                      :apm_enabled => true,
                      :agent5_enable => true,
                  }}
                  it { should_not contain_concat__fragment('datadog apm footer').with(
                  'order' => '07',
                  )}
              end
              context 'with extra_template and APM enabled' do
                  let(:params) {{
                      :extra_template => 'custom_datadog/extra_template_test.erb',
                      :apm_enabled => true,
                      :apm_env => 'foo',
                      :agent5_enable => true,
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
              context 'with process_agent enabled' do
                  let(:params) {{ :process_enabled => true,
                                  :agent5_enable => true,
                  }}
                  it { should contain_concat__fragment('datadog footer').with(
                  'content' => /^process_agent_enabled: true\n/,
                  )}
              end

              context 'with data scrubbing disabled' do
                let(:params) {{
                    :process_enabled => true,
                    :agent5_enable => true,
                    :scrub_args => false
                }}
                it { should contain_concat__fragment('datadog footer').with(
                  'content' => /^process_agent_enabled: true\n/,
                )}
                it { should contain_concat__fragment('datadog process agent footer').with(
                  'content' => /^\[process.config\]\n/,
                )}
                it { should contain_concat__fragment('datadog process agent footer').with(
                  'content' => /^scrub_args: false\n/,
                )}
                it { should contain_concat__fragment('datadog process agent footer').with(
                  'content' => /^custom_sensitive_words: \n/,
                )}
              end

              context 'with data scrubbing enabled with custom sensitive_words' do
                let(:params) {{
                    :process_enabled => true,
                    :agent5_enable => true,
                    :custom_sensitive_words => ['consul_token','dd_key']
                }}
                it { should contain_concat__fragment('datadog footer').with(
                  'content' => /^process_agent_enabled: true\n/,
                )}
                it { should contain_concat__fragment('datadog process agent footer').with(
                  'content' => /^\[process.config\]\n/,
                )}
                it { should contain_concat__fragment('datadog process agent footer').with(
                  'content' => /^scrub_args: true\n/,
                )}
                it { should contain_concat__fragment('datadog process agent footer').with(
                  'content' => /^custom_sensitive_words: consul_token,dd_key\n/,
                )}
              end

              context 'with service provider override' do
                let(:params) {{
                    :service_provider => 'upstart',
                }}
                it do
                  should contain_service('datadog-agent')\
                    .that_requires('package[datadog-agent]')
                end
                it do
                  should contain_service('datadog-agent').with(
                    'provider' => 'upstart',
                    'ensure' => 'running',
                  )
                end
              end

            end
          end

          if DEBIAN_OS.include?(operatingsystem)
            it do
              should contain_class('datadog_agent::ubuntu::agent5')\
                  .with_apt_keyserver('hkp://keyserver.ubuntu.com:80')
            end
            context 'use backup keyserver' do
              let(:params) {{
                  :use_apt_backup_keyserver => true,
                  :agent5_enable => true,
              }}
              it do
                  should contain_class('datadog_agent::ubuntu::agent5')\
                      .with_apt_keyserver('hkp://pool.sks-keyservers.net:80')
              end
            end
          elsif REDHAT_OS.include?(operatingsystem)
            it { should contain_class('datadog_agent::redhat::agent5') }
          end
        end
      end

      describe "datadog_agent 6 class with reports on #{operatingsystem}" do
        let(:params) { { puppet_run_reports: true } }
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: getosfamily(operatingsystem)
          }
        end

        if WINDOWS_OS.include?(operatingsystem)
          it "reports should raise on Windows" do
            should raise_error(Puppet::Error, /Reporting is not yet supported from a Windows host/)
          end
        else
          it { should compile.with_all_deps }

          it { should contain_class('datadog_agent') }

          it { should contain_class('datadog_agent::reports') }
        end

      end

      describe "datadog_agent 6 class common actions on #{operatingsystem}" do
        let(:params) { { puppet_run_reports: false } }
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: getosfamily(operatingsystem)
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('datadog_agent') }

        describe 'datadog_agent imports the default params' do
          it { should contain_class('datadog_agent::params') }
        end

        config_dir = WINDOWS_OS.include?(operatingsystem) ? 'C:/ProgramData/Datadog' : "/etc/datadog-agent"
        config_yaml_file = config_dir + "/datadog.yaml"
        log_file = WINDOWS_OS.include?(operatingsystem) ? 'C:/ProgramData/Datadog/logs/agent.log' : '\/var\/log\/datadog\/agent.log'

        it { should contain_file(config_dir) }
        it { should contain_file(config_yaml_file) }
        it { should contain_file(config_dir + '/conf.d').with_ensure('directory') }

        # Agent 5 files
        it { should_not contain_file('/etc/dd-agent') }
        it { should_not contain_concat('/etc/dd-agent/datadog.conf') }
        it { should_not contain_file('/etc/dd-agent/conf.d').with_ensure('directory') }

        describe 'agent6 parameter check' do
          context 'with defaults' do
            context 'for basic beta settings' do
              it { should contain_file(config_yaml_file).with(
              'content' => /^api_key: your_API_key\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => Regexp.new('^conf_path: \"{0,1}' + config_dir + '/conf.d' + '"{0,1}\n'),
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^cmd_port: \"{0,1}5001\"{0,1}\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^collect_ec2_tags: false\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^dd_url: ''\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^site: datadoghq.com\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^enable_metadata_collection: true\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^dogstatsd_port: \"{0,1}8125\"{0,1}\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => Regexp.new('^log_file: \"{0,1}' + log_file + '"{0,1}\n'),
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^log_level: info\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n\ \ enabled: false\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ apm_non_local_traffic: false\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n\ \ enabled: disabled\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ scrub_args: true\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ custom_sensitive_words: \[\]\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^logs_enabled: false\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^logs_config:\n\ \ container_collect_all: false\n/,
              )}
              it { should contain_file(config_yaml_file).without(
              'content' => /^hostname: .*\n/,
              )}
              it { should contain_file(config_yaml_file).without(
              'content' => /^statsd_forward_host: .*\n/,
              )}
              it { should contain_file(config_yaml_file).without(
              'content' => /^statsd_forward_port: ,*\n/,
              )}
            end
          end

          context 'with modified defaults' do
            context 'hostname override' do
              let(:params) {{
                  :host => 'my_custom_hostname',
                  :collect_ec2_tags => true,
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^hostname: my_custom_hostname\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^collect_ec2_tags: true\n/,
              )}
            end
            context 'datadog EU' do
              let(:params) {{
                  :datadog_site => 'datadoghq.eu',
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^site: datadoghq.eu\n/,
              )}
            end
            context 'forward statsd settings set' do
              let(:params) {{
                  :statsd_forward_host => 'foo',
                  :statsd_forward_port => 1234,
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^statsd_forward_host: foo\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^statsd_forward_port: 1234\n/,
              )}
            end
            context 'deprecated proxy settings' do
              let(:params) {{
                  :proxy_host => 'foo',
                  :proxy_port => 1234,
                  :proxy_user => 'bar',
                  :proxy_password => 'abcd1234',
              }}
              it { is_expected.to contain_notify(
                  'Setting proxy_host will have no effect on agent6 please use agent6_extra_options to set your proxy')
              }
              it { is_expected.to contain_notify(
                  'Setting proxy_port will have no effect on agent6 please use agent6_extra_options to set your proxy')
              }
              it { is_expected.to contain_notify(
                  'Setting proxy_user will have no effect on agent6 please use agent6_extra_options to set your proxy')
              }
              it { is_expected.to contain_notify(
                  'Setting proxy_password will have no effect on agent6 please use agent6_extra_options to set your proxy')
              }
            end
            context 'deprecated proxy settings with default values' do
              let(:params) {{
                  :proxy_host => '',
                  :proxy_port => '',
                  :proxy_user => '',
                  :proxy_password => '',
              }}
              it { is_expected.not_to contain_notify(
                  'Setting proxy_host will have no effect on agent6 please use agent6_extra_options to set your proxy')
              }
              it { is_expected.not_to contain_notify(
                  'Setting proxy_port will have no effect on agent6 please use agent6_extra_options to set your proxy')
              }
              it { is_expected.not_to contain_notify(
                  'Setting proxy_user will have no effect on agent6 please use agent6_extra_options to set your proxy')
              }
              it { is_expected.not_to contain_notify(
                  'Setting proxy_password will have no effect on agent6 please use agent6_extra_options to set your proxy')
              }
            end
          end

          context 'with additional agents config' do
            context 'with extra_options and APM enabled' do
              let(:params) {{
                  :apm_enabled => true,
                  :apm_env => 'foo',
                  :agent6_extra_options => {
                      'apm_config' => {
                          'foo' => 'bar',
                          'bar' => 'haz',
                      }
                  }
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n\ \ enabled: true\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ foo: bar\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ bar: haz\n/,
              )}
            end

            context 'with APM non local traffic enabled' do
              let(:params) {{
                  :apm_enabled => true,
                  :apm_env => 'foo',
                  :apm_non_local_traffic => true,
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n\ \ enabled: true\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ apm_non_local_traffic: true\n/,
              )}
            end

            context 'with apm_enabled set to true and apm_analyzed_spans specified' do
              let(:params) {{
                  :apm_enabled  => true,
                  :apm_analyzed_spans => {
                      'foo|bar' => 0.5,
                      'haz|qux' => 0.1
                  },
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n\ \ enabled: true\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ analyzed_spans:\n\ \ \ \ foo|bar: 0.5\n\ \ \ \ haz|qux: 0.1\n/,
              )}
            end
            context 'with extra_options and Process enabled' do
              let(:params) {{
                  :apm_enabled => false,
                  :process_enabled => true,
                  :agent6_extra_options => {
                      'process_config' => {
                          'foo' => 'bar',
                          'bar' => 'haz',
                      }
                  }
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^apm_config:\n\ \ enabled: false\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n\ \ enabled: 'true'\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ foo: bar\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ bar: haz\n/,
              )}
            end
            context 'with extra_options and process options overriden' do
              let(:params) {{
                  :process_enabled => true,
                  :agent6_extra_options => {
                      'process_config' => {
                          'enabled' => 'disabled',
                          'foo' => 'bar',
                          'bar' => 'haz',
                      }
                  }
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n\ \ enabled: disabled\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ foo: bar\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ bar: haz\n/,
              )}
            end
          end

          context 'with data scrubbing custom options' do
            context 'with data scrubbing disabled' do
              let(:params) {{
                  :process_enabled => true,
                  :scrub_args => false
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n\ \ enabled: 'true'\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ scrub_args: false\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ custom_sensitive_words: \[\]\n/,
              )}
            end

            context 'with data scrubbing enabled with custom sensitive_words' do
              let(:params) {{
                  :process_enabled => true,
                  :custom_sensitive_words => ['consul_token','dd_key']
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^process_config:\n\ \ enabled: 'true'\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ scrub_args: true\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ -\ consul_token\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^\ \ -\ dd_key\n/,
              )}
            end

            context 'with logs enabled' do
              let(:params) {{
                  :logs_enabled => true,
                  :container_collect_all => true
              }}
              it { should contain_file(config_yaml_file).with(
              'content' => /^logs_enabled: true\n/,
              )}
              it { should contain_file(config_yaml_file).with(
              'content' => /^logs_config:\n\ \ container_collect_all: true\n/,
              )}
            end

            if !WINDOWS_OS.include?(operatingsystem)
              context 'with service provider override' do
                let(:params) {{
                    :service_provider => 'upstart',
                }}
                it do
                  should contain_service('datadog-agent')\
                    .that_requires('package[datadog-agent]')
                end
                it do
                  should contain_service('datadog-agent').with(
                    'provider' => 'upstart',
                    'ensure' => 'running',
                  )
                end
              end
            end

          end
        end
      end
    end
  end

  context "with facts to tags set" do
    describe "ensure facts_array outputs a list of tags" do
      let(:params) { { puppet_run_reports: true, facts_to_tags: ['osfamily', 'facts_array']} }
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
