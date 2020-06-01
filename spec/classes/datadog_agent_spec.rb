require 'spec_helper'

describe 'datadog_agent' do
  unless RSpec::Support::OS.windows?
    context 'unsupported operating system' do
      describe 'datadog_agent class without any parameters on Solaris/Nexenta' do
        let(:facts) do
          {
            osfamily:         'Solaris',
            operatingsystem:  'Nexenta',
          }
        end

        it do
          expect {
            is_expected.to contain_package('module')
          }.to raise_error(Puppet::Error, %r{Unsupported operatingsystem: Nexenta})
        end
      end
    end

    context 'autodetect major version agent 5' do
      let(:params) do
        {
          agent_version: '5.15.1',
        }
      end
      let(:facts) do
        {
          osfamily: 'debian',
          operatingsystem: 'Ubuntu',
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+main})
      end
    end

    context 'autodetect major version agent 6' do
      let(:params) do
        {
          agent_version: '6.15.1',
        }
      end
      let(:facts) do
        {
          osfamily: 'debian',
          operatingsystem: 'Ubuntu',
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+6})
      end
    end

    context 'autodetect major version agent 7' do
      let(:params) do
        {
          agent_version: '7.15.1',
        }
      end
      let(:facts) do
        {
          osfamily: 'debian',
          operatingsystem: 'Ubuntu',
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+7})
      end
    end

    context 'autodetect major version agent with suffix and release' do
      let(:params) do
        {
          agent_version: '1:6.15.1~rc.1-1',
        }
      end
      let(:facts) do
        {
          osfamily: 'debian',
          operatingsystem: 'Ubuntu',
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+6})
      end
    end

    context 'autodetect major version agent with windows suffix and release' do
      let(:params) do
        {
          agent_version: '1:6.15.1-rc.1-1',
        }
      end
      let(:facts) do
        {
          osfamily: 'debian',
          operatingsystem: 'Ubuntu',
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+6})
      end
    end

    context 'autodetect major version agent with release' do
      let(:params) do
        {
          agent_version: '1:6.15.1-1',
        }
      end
      let(:facts) do
        {
          osfamily: 'debian',
          operatingsystem: 'Ubuntu',
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+6})
      end
    end
  end

  # Test all supported OSes
  context 'all supported operating systems' do
    ALL_OS.each do |operatingsystem|
      let(:facts) do
        {
          operatingsystem: operatingsystem,
          osfamily: getosfamily(operatingsystem),
        }
      end

      if WINDOWS_OS.include?(operatingsystem)
        describe 'starts service on #{operatingsystem}' do
          it do
            is_expected.to contain_service('datadogagent').with('ensure' => 'running').that_requires('package[Datadog Agent]')
          end
        end
      else
        describe 'starts service on #{operatingsystem}' do
          it do
            is_expected.to contain_service('datadog-agent').with('ensure' => 'running').that_requires('package[datadog-agent]')
          end
        end
        describe 'starts service overriding provider on #{operatingsystem}' do
          let(:params) do
            {
              service_provider: 'systemd',
            }
          end

          it do
            is_expected.to contain_service('datadog-agent').with(
              'provider' => 'systemd',
              'ensure' => 'running',
            )
          end
        end
      end

      describe "datadog_agent 5 class common actions on #{operatingsystem}" do
        let(:params) do
          {
            puppet_run_reports: true,
            agent_major_version: 5,
          }
        end
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: getosfamily(operatingsystem),
          }
        end

        if WINDOWS_OS.include?(operatingsystem)
          it 'agent 5 should raise on Windows' do
            is_expected.to raise_error(Puppet::Error, %r{Installation of agent 5 with puppet is not supported on Windows})
          end
        else
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('datadog_agent') }

          describe 'datadog_agent imports the default params' do
            it { is_expected.to contain_class('datadog_agent::params') }
          end

          it { is_expected.to contain_file('/etc/datadog-agent') }
          it { is_expected.to contain_file('/etc/dd-agent') }
          it { is_expected.to contain_concat('/etc/dd-agent/datadog.conf') }
          it { is_expected.to contain_file('/etc/dd-agent/conf.d').with_ensure('directory') }

          it { is_expected.to contain_class('datadog_agent::reports') }

          describe 'parameter check' do
            context 'with defaults' do
              context 'for proxy' do
                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{dd_url: https://app.datadoghq.com\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^# proxy_host:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^# proxy_port:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^# proxy_user:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^# proxy_password:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^# skip_ssl_validation: no\n},
                  )
                }
              end

              context 'for general' do
                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^api_key: your_API_key\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^# hostname:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^non_local_traffic: false\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^collect_ec2_tags: false\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^collect_instance_metadata: true\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{# recent_point_threshold: 30\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# listen_port: 17123\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# graphite_listen_port: 17124\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{# additional_checksd: /etc/dd-agent/checks.d/\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^use_curl_http_client: false\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# device_blacklist_re: .*\\/dev\\/mapper\\/lxc-box.*\n},
                  )
                }
              end

              context 'for pup' do
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^use_pup: no\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# pup_port: 17125\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# pup_interface: localhost\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{# pup_url: http://localhost:17125\n},
                  )
                }
              end

              context 'for dogstatsd' do
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# bind_host: localhost\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^use_dogstatsd: yes\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^dogstatsd_port: 8125\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{# dogstatsd_target: http://localhost:17123\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# dogstatsd_interval: 10\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^dogstatsd_normalize: yes\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# statsd_forward_host: address_of_own_statsd_server\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# statsd_forward_port: 8125\n},
                  )
                }
              end

              context 'for ganglia' do
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# ganglia_host: localhost\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# ganglia_port: 8651\n},
                  )
                }
              end

              context 'for logging' do
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^log_level: INFO\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^log_to_syslog: yes\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{# collector_log_file: /var/log/datadog/collector.log\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{# forwarder_log_file: /var/log/datadog/forwarder.log\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{# dogstatsd_log_file: /var/log/datadog/dogstatsd.log\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with
                  # 'content' => %r{# pup_log_file:        /var/log/datadog/pup.log\n},
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# syslog_host:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^# syslog_port:\n},
                  )
                }
              end

              context 'for service_discovery' do
                it {
                  is_expected.to contain_concat__fragment('datadog footer').without(
                    'content' => %r{^service_discovery_backend:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').without(
                    'content' => %r{^sd_config_backend:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').without(
                    'content' => %r{^sd_backend_host:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').without(
                    'content' => %r{^sd_backend_port:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').without(
                    'content' => %r{^sd_template_dir:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').without(
                    'content' => %r{^consul_token:\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').without(
                    'content' => %r{^# sd_jmx_enable:\n},
                  )
                }
              end

              context 'for APM' do
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^apm_enabled: false\n},
                  )
                }
              end
            end

            context 'with user provided paramaters' do
              context 'with a custom dd_url' do
                let(:params) do
                  {
                    dd_url: 'https://notaurl.datadoghq.com',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{dd_url: https://notaurl.datadoghq.com\n},
                  )
                }
              end
              context 'with a custom proxy_host' do
                let(:params) do
                  {
                    proxy_host: 'localhost',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^proxy_host: localhost\n},
                  )
                }
              end
              context 'with a custom proxy_port' do
                let(:params) do
                  {
                    proxy_port: '1234',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^proxy_port: 1234\n},
                  )
                }
              end
              context 'with a custom proxy_port, specified as an integer' do
                let(:params) do
                  {
                    proxy_port: 1234,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^proxy_port: 1234\n},
                  )
                }
              end
              context 'with a custom proxy_user' do
                let(:params) do
                  {
                    proxy_user: 'notauser',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^proxy_user: notauser\n},
                  )
                }
              end
              context 'with a custom api_key' do
                let(:params) do
                  {
                    api_key: 'notakey',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^api_key: notakey\n},
                  )
                }
              end
              context 'with a custom hostname' do
                let(:params) do
                  {
                    host: 'notahost',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^hostname: notahost\n},
                  )
                }
              end
              context 'with non_local_traffic set to true' do
                let(:params) do
                  {
                    non_local_traffic: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^non_local_traffic: true\n},
                  )
                }
              end
              # Should expand testing to cover changes to the case upcase
              context 'with log level set to critical' do
                let(:params) do
                  {
                    log_level: 'critical',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^log_level: CRITICAL\n},
                  )
                }
              end
              context 'with a custom hostname' do
                let(:params) do
                  {
                    host: 'notahost',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^hostname: notahost\n},
                  )
                }
              end
              context 'with log_to_syslog set to false' do
                let(:params) do
                  {
                    log_to_syslog: false,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^log_to_syslog: no\n},
                  )
                }
              end
              context 'with skip_ssl_validation set to true' do
                let(:params) do
                  {
                    skip_ssl_validation: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog header').with(
                    'content' => %r{^skip_ssl_validation: true\n},
                  )
                }
              end
              context 'with collect_ec2_tags set to yes' do
                let(:params) do
                  {
                    collect_ec2_tags: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^collect_ec2_tags: true\n},
                  )
                }
              end
              context 'with collect_instance_metadata set to no' do
                let(:params) do
                  {
                    collect_instance_metadata: false,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^collect_instance_metadata: false\n},
                  )
                }
              end
              context 'with recent_point_threshold set to 60' do
                let(:params) do
                  {
                    recent_point_threshold: '60',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^recent_point_threshold: 60\n},
                  )
                }
              end
              context 'with a custom port set to 17125' do
                let(:params) do
                  {
                    listen_port: '17125',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^listen_port: 17125\n},
                  )
                }
              end
              context 'with a custom port set to 17125, specified as an integer' do
                let(:params) do
                  {
                    listen_port: 17_125,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^listen_port: 17125\n},
                  )
                }
              end
              context 'listening for graphite data on port 17124' do
                let(:params) do
                  {
                    graphite_listen_port: '17124',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^graphite_listen_port: 17124\n},
                  )
                }
              end
              context 'listening for graphite data on port 17124, port specified as an integer' do
                let(:params) do
                  {
                    graphite_listen_port: 17_124,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^graphite_listen_port: 17124\n},
                  )
                }
              end
              context 'with configuration for a custom checks.d' do
                let(:params) do
                  {
                    additional_checksd: '/etc/dd-agent/checks_custom.d',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{additional_checksd: /etc/dd-agent/checks_custom.d\n},
                  )
                }
              end
              context 'with configuration for a custom checks.d' do
                let(:params) do
                  {
                    additional_checksd: '/etc/dd-agent/checks_custom.d',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{additional_checksd: /etc/dd-agent/checks_custom.d\n},
                  )
                }
              end
              context 'with configuration for a custom checks.d' do
                let(:params) do
                  {
                    additional_checksd: '/etc/dd-agent/checks_custom.d',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{additional_checksd: /etc/dd-agent/checks_custom.d\n},
                  )
                }
              end
              context 'with using the Tornado HTTP client' do
                let(:params) do
                  {
                    use_curl_http_client: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^use_curl_http_client: true\n},
                  )
                }
              end
              context 'with a custom bind_host' do
                let(:params) do
                  {
                    bind_host: 'test',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^bind_host: test\n},
                  )
                }
              end
              context 'with pup enabled' do
                let(:params) do
                  {
                    use_pup: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^use_pup: yes\n},
                  )
                }
              end
              context 'with a custom pup_port' do
                let(:params) do
                  {
                    pup_port: '17126',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^pup_port: 17126\n},
                  )
                }
              end
              context 'with a custom pup_port, specified as an integer' do
                let(:params) do
                  {
                    pup_port: 17_126,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^pup_port: 17126\n},
                  )
                }
              end
              context 'with a custom pup_interface' do
                let(:params) do
                  {
                    pup_interface: 'notalocalhost',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^pup_interface: notalocalhost\n},
                  )
                }
              end
              context 'with a custom pup_url' do
                let(:params) do
                  {
                    pup_url: 'http://localhost:17126',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{pup_url: http://localhost:17126\n},
                  )
                }
              end
              context 'with use_dogstatsd set to no' do
                let(:params) do
                  {
                    use_dogstatsd: false,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^use_dogstatsd: no\n},
                  )
                }
              end
              context 'with use_dogstatsd set to yes' do
                let(:params) do
                  {
                    use_dogstatsd: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^use_dogstatsd: yes\n},
                  )
                }
              end
              context 'with dogstatsd_port set to 8126 - must be specified as an integer!' do
                let(:params) do
                  {
                    dogstatsd_port: 8126,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^dogstatsd_port: 8126\n},
                  )
                }
              end
              context 'with dogstatsd_port set to 8126' do
                let(:params) do
                  {
                    dogstatsd_port: 8126,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^dogstatsd_port: 8126\n},
                  )
                }
              end
              context 'with dogstatsd_target set to localhost:17124' do
                let(:params) do
                  {
                    dogstatsd_target: 'http://localhost:17124',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{dogstatsd_target: http://localhost:17124\n},
                  )
                }
              end
              context 'with dogstatsd_interval set to 5' do
                let(:params) do
                  {
                    dogstatsd_interval: '5',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^dogstatsd_interval: 5\n},
                  )
                }
              end
              context 'with dogstatsd_interval set to 5' do
                let(:params) do
                  {
                    dogstatsd_interval: '5',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^dogstatsd_interval: 5\n},
                  )
                }
              end
              context 'with dogstatsd_normalize set to false' do
                let(:params) do
                  {
                    dogstatsd_normalize: false,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^dogstatsd_normalize: no\n},
                  )
                }
              end
              context 'with statsd_forward_host set to localhost:3958' do
                let(:params) do
                  {
                    statsd_forward_host: 'localhost:3958',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^statsd_forward_host: localhost:3958\n},
                  )
                }
              end
              context 'with statsd_forward_port set to 8126' do
                let(:params) do
                  {
                    statsd_forward_port: '8126',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^statsd_forward_port: 8126\n},
                  )
                }
              end
              context 'with statsd_forward_port set to 8126, specified as an integer' do
                let(:params) do
                  {
                    statsd_forward_port: 8126,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^statsd_forward_port: 8126\n},
                  )
                }
              end
              context 'with device_blacklist_re set to test' do
                let(:params) do
                  {
                    device_blacklist_re: 'test',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^device_blacklist_re: test\n},
                  )
                }
              end
              context 'with device_blacklist_re set to test' do
                let(:params) do
                  {
                    device_blacklist_re: 'test',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^device_blacklist_re: test\n},
                  )
                }
              end
              context 'with ganglia_host set to localhost and ganglia_port set to 12345' do
                let(:params) do
                  {
                    ganglia_host: 'testhost',
                    ganglia_port: '12345',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^ganglia_port: 12345\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^ganglia_host: testhost\n},
                  )
                }
              end
              context 'with ganglia_host set to localhost and ganglia_port set to 12345, port specified as an integer' do
                let(:params) do
                  {
                    ganglia_host: 'testhost',
                    ganglia_port: 12_345,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^ganglia_port: 12345\n},
                  )
                }
              end
              context 'with dogstreams set to /path/to/log1:/path/to/parser' do
                let(:params) do
                  {
                    dogstreams: ['/path/to/log1:/path/to/parser'],
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{dogstreams: /path/to/log1:/path/to/parser\n},
                  )
                }
              end
              context 'with custom_emitters set to /test/emitter' do
                let(:params) do
                  {
                    custom_emitters: '/test/emitter/',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{custom_emitters: /test/emitter/\n},
                  )
                }
              end
              context 'with custom_emitters set to /test/emitter' do
                let(:params) do
                  {
                    custom_emitters: '/test/emitter/',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{custom_emitters: /test/emitter/\n},
                  )
                }
              end
              context 'with collector_log_file set to /test/log' do
                let(:params) do
                  {
                    collector_log_file: '/test/log',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{collector_log_file: /test/log\n},
                  )
                }
              end
              context 'with forwarder_log_file set to /test/log' do
                let(:params) do
                  {
                    forwarder_log_file: '/test/log',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{forwarder_log_file: /test/log\n},
                  )
                }
              end
              context 'with forwarder_log_file set to /test/log' do
                let(:params) do
                  {
                    forwarder_log_file: '/test/log',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{forwarder_log_file: /test/log\n},
                  )
                }
              end
              context 'with dogstatsd_log_file set to /test/log' do
                let(:params) do
                  {
                    dogstatsd_log_file: '/test/log',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{dogstatsd_log_file: /test/log\n},
                  )
                }
              end
              context 'with pup_log_file set to /test/log' do
                let(:params) do
                  {
                    pup_log_file: '/test/log',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^pup_log_file: /test/log\n},
                  )
                }
              end
              context 'with syslog location set to localhost' do
                let(:params) do
                  {
                    syslog_host: 'localhost',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^syslog_host: localhost\n},
                  )
                }
              end
              context 'with syslog port set to 8080' do
                let(:params) do
                  {
                    syslog_port: '8080',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^syslog_port: 8080\n},
                  )
                }
              end
              context 'with syslog port set to 8080, specified as an integer' do
                let(:params) do
                  {
                    syslog_port: 8080,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^syslog_port: 8080\n},
                  )
                }
              end
              context 'with apm_enabled set to true' do
                let(:params) do
                  {
                    apm_enabled: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^apm_enabled: true\n},
                  )
                }
              end
              context 'with apm_enabled set to true and env specified' do
                let(:params) do
                  {
                    apm_enabled: true,
                    apm_env: 'foo',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^apm_enabled: true\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog apm footer').with(
                    'content' => %r{^\[trace.agent\]\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog apm footer').with(
                    'content' => %r{^env: foo\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog apm footer').with(
                    'order' => '07',
                  )
                }
              end
              context 'with apm_enabled and apm_analyzed_spans set' do
                let(:params) do
                  {
                    apm_enabled: true,
                    agent_major_version: 5,
                    apm_analyzed_spans: {
                      'foo|bar' => 0.5,
                      'haz|qux' => 0.1,
                    },
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^apm_enabled: true\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog apm footer').with(
                    'content' => %r{^\[trace.analyzed_spans\]\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog apm footer').with(
                    'content' => %r{^\[trace.analyzed_spans\]\nfoo|bar: 0.5\nhaz|qux: 0.1},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog apm footer').with(
                    'order' => '07',
                  )
                }
              end
              context 'with service_discovery enabled' do
                let(:params) do
                  {
                    service_discovery_backend: 'docker',
                    sd_config_backend: 'etcd',
                    sd_backend_host: 'localhost',
                    sd_backend_port: 8080,
                    sd_jmx_enable: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^service_discovery_backend: docker\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^sd_config_backend: etcd\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^sd_backend_host: localhost\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^sd_backend_port: 8080\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^sd_jmx_enable: true\n},
                  )
                }
              end
              context 'with extra_template enabled' do
                let(:params) do
                  {
                    extra_template: 'custom_datadog/extra_template_test.erb',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog extra_template footer').with(
                    'order' => '06',
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog extra_template footer').with(
                    'content' => %r{^# extra template is here\n},
                  )
                }
                it {
                  is_expected.not_to contain_concat__fragment('datadog apm footer').with(
                    'order' => '07',
                  )
                }
              end
              context 'with APM enabled' do
                let(:params) do
                  {
                    apm_enabled: true,
                    apm_env: 'foo',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog apm footer').with(
                    'order' => '07',
                  )
                }
              end
              context 'with APM enabled but no APM env' do
                let(:params) do
                  {
                    apm_enabled: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.not_to contain_concat__fragment('datadog apm footer').with(
                    'order' => '07',
                  )
                }
              end
              context 'with extra_template and APM enabled' do
                let(:params) do
                  {
                    extra_template: 'custom_datadog/extra_template_test.erb',
                    apm_enabled: true,
                    apm_env: 'foo',
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog extra_template footer').with(
                    'order' => '06',
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog extra_template footer').with(
                    'content' => %r{^# extra template is here\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog apm footer').with(
                    'order' => '07',
                  )
                }
              end
              context 'with process_agent enabled' do
                let(:params) do
                  {
                    process_enabled: true,
                    agent_major_version: 5,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^process_agent_enabled: true\n},
                  )
                }
              end

              context 'with data scrubbing disabled' do
                let(:params) do
                  {
                    process_enabled: true,
                    agent_major_version: 5,
                    scrub_args: false,
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^process_agent_enabled: true\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog process agent footer').with(
                    'content' => %r{^\[process.config\]\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog process agent footer').with(
                    'content' => %r{^scrub_args: false\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog process agent footer').with(
                    'content' => %r{^custom_sensitive_words: \n},
                  )
                }
              end

              context 'with data scrubbing enabled with custom sensitive_words' do
                let(:params) do
                  {
                    process_enabled: true,
                    agent_major_version: 5,
                    custom_sensitive_words: ['consul_token', 'dd_key'],
                  }
                end

                it {
                  is_expected.to contain_concat__fragment('datadog footer').with(
                    'content' => %r{^process_agent_enabled: true\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog process agent footer').with(
                    'content' => %r{^\[process.config\]\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog process agent footer').with(
                    'content' => %r{^scrub_args: true\n},
                  )
                }
                it {
                  is_expected.to contain_concat__fragment('datadog process agent footer').with(
                    'content' => %r{^custom_sensitive_words: consul_token,dd_key\n},
                  )
                }
              end
            end
          end

          if DEBIAN_OS.include?(operatingsystem)
            it do
              is_expected.to contain_class('datadog_agent::ubuntu')\
                .with_apt_keyserver('hkp://keyserver.ubuntu.com:80')
            end
            context 'use backup keyserver' do
              let(:params) do
                {
                  use_apt_backup_keyserver: true,
                  agent_major_version: 5,
                }
              end

              it do
                is_expected.to contain_class('datadog_agent::ubuntu')\
                  .with_apt_keyserver('hkp://pool.sks-keyservers.net:80')
              end
            end
          elsif REDHAT_OS.include?(operatingsystem)
            it { is_expected.to contain_class('datadog_agent::redhat') }
          end
        end
      end

      describe "datadog_agent 6/7 class with reports on #{operatingsystem}" do
        let(:params) do
          {
            puppet_run_reports: true,
          }
        end
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: getosfamily(operatingsystem),
          }
        end

        if WINDOWS_OS.include?(operatingsystem)
          it 'reports should raise on Windows' do
            is_expected.to raise_error(Puppet::Error, %r{Reporting is not yet supported from a Windows host})
          end
        else
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('datadog_agent') }

          it { is_expected.to contain_class('datadog_agent::reports') }
        end
      end

      describe "datadog_agent 6/7 class common actions on #{operatingsystem}" do
        let(:params) do
          {
            puppet_run_reports: false,
          }
        end
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: getosfamily(operatingsystem),
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('datadog_agent') }

        describe 'datadog_agent imports the default params' do
          it { is_expected.to contain_class('datadog_agent::params') }
        end

        config_dir = WINDOWS_OS.include?(operatingsystem) ? 'C:/ProgramData/Datadog' : '/etc/datadog-agent'
        config_yaml_file = File.join(config_dir, 'datadog.yaml')
        install_info_file = File.join(config_dir, 'install_info')
        log_file = WINDOWS_OS.include?(operatingsystem) ? 'C:/ProgramData/Datadog/logs/agent.log' : '\/var\/log\/datadog\/agent.log'

        it { is_expected.to contain_file(config_dir) }
        it { is_expected.to contain_file(config_yaml_file) }
        it { is_expected.to contain_file(install_info_file) }
        it { is_expected.to contain_file(config_dir + '/conf.d').with_ensure('directory') }

        # Agent 5 files
        it { is_expected.not_to contain_file('/etc/dd-agent') }
        it { is_expected.not_to contain_concat('/etc/dd-agent/datadog.conf') }
        it { is_expected.not_to contain_file('/etc/dd-agent/conf.d').with_ensure('directory') }

        describe 'install_info check' do
          let!(:install_info) do
            contents = catalogue.resource('file', install_info_file).send(:parameters)[:content]
            YAML.safe_load(contents)
          end

          it 'adds an install_info' do
            expect(install_info['install_method']).to match(
              'tool' => 'puppet',
              'tool_version' => %r{^puppet-(\d+\.\d+\.\d+|unknown)$},
              'installer_version' => %r{^datadog_module-\d+\.\d+\.\d+$},
            )
          end
        end

        describe 'agent6 parameter check' do
          context 'with defaults' do
            context 'for basic beta settings' do
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^api_key: your_API_key\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => Regexp.new('^confd_path: \"{0,1}' + config_dir + '/conf.d' + '"{0,1}\n'),
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^cmd_port: \"{0,1}5001\"{0,1}\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^collect_ec2_tags: false\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^dd_url: ''\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^site: datadoghq.com\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^enable_metadata_collection: true\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^dogstatsd_port: \"{0,1}8125\"{0,1}\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => Regexp.new('^log_file: \"{0,1}' + log_file + '"{0,1}\n'),
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^log_level: info\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n\ \ enabled: false\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ apm_non_local_traffic: false\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n\ \ enabled: disabled\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ scrub_args: true\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ custom_sensitive_words: \[\]\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^logs_enabled: false\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^logs_config:\n\ \ container_collect_all: false\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).without(
                  'content' => %r{^hostname: .*\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).without(
                  'content' => %r{^statsd_forward_host: .*\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).without(
                  'content' => %r{^statsd_forward_port: ,*\n},
                )
              }
            end
          end

          context 'with modified defaults' do
            context 'hostname override' do
              let(:params) do
                {
                  host: 'my_custom_hostname',
                  collect_ec2_tags: true,
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^hostname: my_custom_hostname\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^collect_ec2_tags: true\n},
                )
              }
            end
            context 'datadog EU' do
              let(:params) do
                {
                  datadog_site: 'datadoghq.eu',
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^site: datadoghq.eu\n},
                )
              }
            end
            context 'forward statsd settings set' do
              let(:params) do
                {
                  statsd_forward_host: 'foo',
                  statsd_forward_port: 1234,
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^statsd_forward_host: foo\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^statsd_forward_port: 1234\n},
                )
              }
            end
            context 'deprecated proxy settings' do
              let(:params) do
                {
                  proxy_host: 'foo',
                  proxy_port: 1234,
                  proxy_user: 'bar',
                  proxy_password: 'abcd1234',
                }
              end

              it {
                is_expected.to contain_notify(
                  'Setting proxy_host is only used with Agent 5. Please use agent_extra_options to set your proxy',
                )
              }
              it {
                is_expected.to contain_notify(
                  'Setting proxy_port is only used with Agent 5. Please use agent_extra_options to set your proxy',
                )
              }
              it {
                is_expected.to contain_notify(
                  'Setting proxy_user is only used with Agent 5. Please use agent_extra_options to set your proxy',
                )
              }
              it {
                is_expected.to contain_notify(
                  'Setting proxy_password is only used with Agent 5. Please use agent_extra_options to set your proxy',
                )
              }
            end
            context 'deprecated proxy settings with default values' do
              let(:params) do
                {
                  proxy_host: '',
                  proxy_port: '',
                  proxy_user: '',
                  proxy_password: '',
                }
              end

              it {
                is_expected.not_to contain_notify(
                  'Setting proxy_host is only used with Agent 5. Please use agent_extra_options to set your proxy',
                )
              }
              it {
                is_expected.not_to contain_notify(
                  'Setting proxy_port is only used with Agent 5. Please use agent_extra_options to set your proxy',
                )
              }
              it {
                is_expected.not_to contain_notify(
                  'Setting proxy_user is only used with Agent 5. Please use agent_extra_options to set your proxy',
                )
              }
              it {
                is_expected.not_to contain_notify(
                  'Setting proxy_password is only used with Agent 5. Please use agent_extra_options to set your proxy',
                )
              }
            end
          end

          context 'with additional agents config' do
            context 'with extra_options and APM enabled' do
              let(:params) do
                {
                  apm_enabled: true,
                  apm_env: 'foo',
                  agent_extra_options: {
                    'apm_config' => {
                      'foo' => 'bar',
                      'bar' => 'haz',
                    },
                  },
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n\ \ enabled: true\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ foo: bar\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ bar: haz\n},
                )
              }
            end

            context 'with APM non local traffic enabled' do
              let(:params) do
                {
                  apm_enabled: true,
                  apm_env: 'foo',
                  apm_non_local_traffic: true,
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n\ \ enabled: true\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ apm_non_local_traffic: true\n},
                )
              }
            end

            context 'with apm_enabled set to true and apm_analyzed_spans specified' do
              let(:params) do
                {
                  apm_enabled: true,
                  apm_analyzed_spans: {
                    'foo|bar' => 0.5,
                    'haz|qux' => 0.1,
                  },
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n\ \ enabled: true\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ analyzed_spans:\n\ \ \ \ foo|bar: 0.5\n\ \ \ \ haz|qux: 0.1\n},
                )
              }
            end

            context 'with apm_enabled set to true and apm_obfuscation specified' do
              let(:params) do
                {
                  apm_enabled: true,
                  apm_obfuscation: {
                    elasticsearch: {
                      enable: true,
                      keep_values: [
                        'user_id',
                        'category_id',
                      ],
                    },
                    redis: {
                      enable: true,
                    },
                    memcached: {
                      enable: true,
                    },
                    http: {
                      remove_query_string: true,
                      remove_paths_with_digits: true,
                    },
                    mongodb: {
                      enable: true,
                      keep_values: [
                        'uid',
                        'cat_id',
                      ],
                    },
                  },
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n\ \ enabled: true\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ obfuscation:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{elasticsearch},
                )
              }
            end

            context 'with extra_options and Process enabled' do
              let(:params) do
                {
                  apm_enabled: false,
                  process_enabled: true,
                  agent_extra_options: {
                    'process_config' => {
                      'foo' => 'bar',
                      'bar' => 'haz',
                    },
                  },
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^apm_config:\n\ \ enabled: false\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n\ \ enabled: 'true'\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ foo: bar\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ bar: haz\n},
                )
              }
            end
            context 'with extra_options and process options overriden' do
              let(:params) do
                {
                  process_enabled: true,
                  agent_extra_options: {
                    'process_config' => {
                      'enabled' => 'disabled',
                      'foo' => 'bar',
                      'bar' => 'haz',
                    },
                  },
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n\ \ enabled: disabled\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ foo: bar\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ bar: haz\n},
                )
              }
            end
          end

          context 'with data scrubbing custom options' do
            context 'with data scrubbing disabled' do
              let(:params) do
                {
                  process_enabled: true,
                  scrub_args: false,
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n\ \ enabled: 'true'\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ scrub_args: false\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ custom_sensitive_words: \[\]\n},
                )
              }
            end

            context 'with data scrubbing enabled with custom sensitive_words' do
              let(:params) do
                {
                  process_enabled: true,
                  custom_sensitive_words: ['consul_token', 'dd_key'],
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^process_config:\n\ \ enabled: 'true'\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ scrub_args: true\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ -\ consul_token\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^\ \ -\ dd_key\n},
                )
              }
            end

            context 'with logs enabled' do
              let(:params) do
                {
                  logs_enabled: true,
                  container_collect_all: true,
                }
              end

              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^logs_enabled: true\n},
                )
              }
              it {
                is_expected.to contain_file(config_yaml_file).with(
                  'content' => %r{^logs_config:\n\ \ container_collect_all: true\n},
                )
              }
            end
          end
        end
      end
    end
  end

  context 'with facts to tags set' do
    describe 'a6 ensure facts_array outputs a list of tags' do
      let(:params) do
        {
          agent_major_version: 6,
          puppet_run_reports: true,
          facts_to_tags: ['osfamily', 'facts_array'],
        }
      end
      let(:facts) do
        {
          operatingsystem: 'CentOS',
          osfamily: 'redhat',
          facts_array: ['one', 'two'],
        }
      end

      it { is_expected.to contain_file('/etc/datadog-agent/datadog.yaml').with_content(%r{tags:\n- osfamily:redhat\n- facts_array:one\n- facts_array:two}) }
    end

    describe 'a5 ensure facts_array outputs a list of tags' do
      let(:params) do
        {
          agent_major_version: 5,
          puppet_run_reports: true,
          facts_to_tags: ['osfamily', 'facts_array'],
        }
      end
      let(:facts) do
        {
          operatingsystem: 'CentOS',
          osfamily: 'redhat',
          facts_array: ['one', 'two'],
        }
      end

      it { is_expected.to contain_concat('/etc/dd-agent/datadog.conf') }
      it { is_expected.to contain_concat__fragment('datadog tags').with_content('tags: ') }
      it { is_expected.to contain_concat__fragment('datadog tag osfamily:redhat').with_content('osfamily:redhat, ') }
      it { is_expected.to contain_concat__fragment('datadog tag facts_array:one').with_content('facts_array:one, ') }
      it { is_expected.to contain_concat__fragment('datadog tag facts_array:two').with_content('facts_array:two, ') }
    end
  end
end
