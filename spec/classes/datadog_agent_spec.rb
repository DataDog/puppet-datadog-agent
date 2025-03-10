require 'spec_helper'

describe 'datadog_agent' do
  unless RSpec::Support::OS.windows?
    context 'unsupported operating system' do
      describe 'datadog_agent class without any parameters on Solaris/Nexenta' do
        let(:facts) do
          {
            os: {
              'architecture' => 'x86_64',
              'family' => 'Solaris',
              'name' => 'Nexenta',
              'release' => {
                'major' => '3',
                'full' => '3.0',
              },
              'distro' => {
                'codename' => 'nexenta',
              }
            },
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
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Ubuntu',
            'release' => {
              'major' => '14',
              'full' => '14.04',
            },
            'distro' => {
              'codename' => 'trusty',
            },
          },
        }
      end

      it do
        expect {
          is_expected.to contain_package('module')
        }.to raise_error(Puppet::Error, %r{agent_major_version must be either 6 or 7, not 5})
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
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Ubuntu',
            'release' => {
              'major' => '14',
              'full' => '14.04',
            },
            'distro' => {
              'codename' => 'trusty',
            },
          },
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+\[signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg\]\s+https://apt.datadoghq.com/\s+stable\s+6})
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
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Ubuntu',
            'release' => {
              'major' => '14',
              'full' => '14.04',
            },
            'distro' => {
              'codename' => 'trusty',
            },
          },
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+\[signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg\]\s+https://apt.datadoghq.com/\s+stable\s+7})
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
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Ubuntu',
            'release' => {
              'major' => '14',
              'full' => '14.04',
            },
            'distro' => {
              'codename' => 'trusty',
            },
          },
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+\[signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg\]\s+https://apt.datadoghq.com/\s+stable\s+6})
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
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Ubuntu',
            'release' => {
              'major' => '14',
              'full' => '14.04',
            },
            'distro' => {
              'codename' => 'trusty',
            },
          },
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+\[signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg\]\s+https://apt.datadoghq.com/\s+stable\s+6})
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
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Ubuntu',
            'release' => {
              'major' => '14',
              'full' => '14.04',
            },
            'distro' => {
              'codename' => 'trusty',
            },
          },
        }
      end

      it do
        is_expected.to contain_file('/etc/apt/sources.list.d/datadog.list')\
          .with_content(%r{deb\s+\[signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg\]\s+https://apt.datadoghq.com/\s+stable\s+6})
      end
    end

    context 'default agent_flavor' do
      let(:params) do
        {
          agent_version: '1:6.15.1-1',
        }
      end
      let(:facts) do
        {
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Ubuntu',
            'release' => {
              'major' => '14',
              'full' => '14.04',
            },
            'distro' => {
              'codename' => 'trusty',
            },
          },
        }
      end

      it do
        is_expected.to contain_package('datadog-agent').with(
          ensure: '1:6.15.1-1',
        )
      end
    end

    context 'specify agent_flavor' do
      let(:params) do
        {
          agent_version: '1:6.15.1-1',
          agent_flavor: 'datadog-iot-agent',
        }
      end
      let(:facts) do
        {
          os: {
            'architecture' => 'x86_64',
            'family' => 'debian',
            'name' => 'Ubuntu',
            'release' => {
              'major' => '14',
              'full' => '14.04',
            },
            'distro' => {
              'codename' => 'trusty',
            },
          },
        }
      end

      it do
        is_expected.to contain_package('datadog-iot-agent').with(
          ensure: '1:6.15.1-1',
        )
      end
    end
  end

  if Gem::Version.new(Puppet.version) >= Gem::Version.new('4.10') # We don't support Windows on Puppet older than 4.10
    context 'windows NPM' do
      let(:facts) do
        {
          os: {
            'architecture' => 'x86_64',
            'family' => 'windows',
            'name' => 'Windows',
            'release' => {
              'major' => '2019',
              'full' => '2019 SP1',
            },
          },
        }
      end

      describe 'with NPM enabled' do
        let(:params) do
          {
            agent_major_version: 7,
            windows_npm_install: true,
            api_key: 'notakey',
            host: 'notahost',
          }
        end

        it do
          is_expected.to contain_package('Datadog Agent').with(
            ensure: 'installed',
            install_options: ['/norestart', { 'APIKEY' => 'notakey', 'HOSTNAME' => 'notahost', 'TAGS' => '""', 'ADDLOCAL' => 'MainApplication,NPM' }],
          )
        end
      end

      describe 'with NPM disabled' do
        let(:params) do
          {
            agent_major_version: 7,
            api_key: 'notakey',
            host: 'notahost',
          }
        end

        it do
          is_expected.to contain_package('Datadog Agent').with(
            ensure: 'installed',
            install_options: ['/norestart', { 'APIKEY' => 'notakey', 'HOSTNAME' => 'notahost', 'TAGS' => '""' }],
          )
        end
      end
    end
  end

  # Test all supported OSes
  context 'all supported operating systems' do
    ALL_OS.each do |operatingsystem|
      let(:facts) do
        {
          os: {
            'architecture' => 'x86_64',
            'family' => getosfamily(operatingsystem),
            'name' => operatingsystem,
            'release' => {
              'major' => getosmajor(operatingsystem),
              'full' => getosrelease(operatingsystem),
            },
            'distro' => {
              'code' => getoscodename(operatingsystem),
            }
          },
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

      describe "datadog_agent 6/7 class with reports on #{operatingsystem}" do
        let(:params) do
          {
            puppet_run_reports: true,
          }
        end
        let(:facts) do
          {
            os: {
              'architecture' => 'x86_64',
              'family' => getosfamily(operatingsystem),
              'name' => operatingsystem,
              'release' => {
                'major' => getosmajor(operatingsystem),
                'full' => getosrelease(operatingsystem),
              },
              'distro' => {
                'codename' => getoscodename(operatingsystem),
              }
            },
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
            os: {
              'architecture' => 'x86_64',
              'family' => getosfamily(operatingsystem),
              'name' => operatingsystem,
              'release' => {
                'major' => getosmajor(operatingsystem),
                'full' => getosrelease(operatingsystem),
              },
              'distro' => {
                'codename' => getoscodename(operatingsystem)
              },
            },
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

        describe 'install_info check' do
          let!(:install_info) do
            contents = catalogue.resource('file', install_info_file).send(:parameters)[:content]
            YAML.safe_load(contents)
          end

          it 'adds an install_info' do
            expect(install_info['install_method']).to match(
              'tool' => 'puppet',
              'tool_version' => %r{^puppet-\d+\.\d+\.\d}, # puppetversion is not set in tests, this field has to be tested manually
              'installer_version' => %r{^datadog_module-\d+\.\d+\.\d},
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

  context 'with trusted_facts to tags set' do
    Puppet::Util::Log.level = :debug
    Puppet::Util::Log.newdestination(:console)

    describe 'a6 ensure facts_array outputs a list of tags' do
      let(:params) do
        {
          agent_major_version: 6,
          puppet_run_reports: true,
          facts_to_tags: ['os.family'],
          trusted_facts_to_tags: ['extensions.trusted_fact', 'extensions.facts_array', 'extensions.facts_hash.actor.first_name'],
        }
      end
      let(:facts) do
        {
          'os' => {
            'architecture' => 'x86_64',
            'family' => 'redhat',
            'name' => 'CentOS',
            'release' => {
              'major' => '6',
              'full' => '6.3',
            },
            'distro' => {
              'codename' => 'santiago',
            }
          },
        }
      end
      let(:trusted_facts) do
        {
          'trusted_fact' => 'test',
          'facts_array' => ['one', 'two'],
          'facts_hash' => {
            'actor' => {
              'first_name' => 'Macaulay',
              'last_name' => 'Culkin',
            },
          },
        }
      end

      it do
        is_expected.to contain_file('/etc/datadog-agent/datadog.yaml')
          .with_content(%r{tags:\n- os.family:redhat\n- extensions.trusted_fact:test\n- extensions.facts_array:one\n- extensions.facts_array:two\n- extensions.facts_hash.actor.first_name:Macaulay})
      end
    end
  end

  context 'with facts to tags set' do
    describe 'a6 ensure facts_array outputs a list of tags' do
      let(:params) do
        {
          agent_major_version: 6,
          puppet_run_reports: true,
          facts_to_tags: ['os.family', 'facts_array', 'facts_hash.actor.first_name', 'looks.like.a.path'],
        }
      end
      let(:facts) do
        {
          'facts_array' => ['one', 'two'],
          'facts_hash' => {
            'actor' => {
              'first_name' => 'Macaulay',
              'last_name' => 'Culkin',
            },
          },
          'looks.like.a.path' => 'but_its_not',
          'os' => {
            'architecture' => 'x86_64',
            'family' => 'redhat',
            'name' => 'CentOS',
            'release' => {
              'major' => '6',
              'full' => '6.3',
            },
            'distro' => {
              'codename' => 'santiago',
            }
          },
        }
      end

      it do
        is_expected.to contain_file('/etc/datadog-agent/datadog.yaml')
          .with_content(%r{tags:\n- os.family:redhat\n- facts_array:one\n- facts_array:two\n- facts_hash.actor.first_name:Macaulay\n- looks.like.a.path:but_its_not})
      end
    end
  end
end
