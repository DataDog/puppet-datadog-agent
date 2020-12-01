require 'spec_helper'

describe 'datadog_agent::integrations::postgres' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/postgres.yaml'
                  else
                    "#{CONF_DIR}/postgres.d/conf.yaml"
                  end

      context 'with default parameters' do
        it { is_expected.to compile }
      end

      context 'with password set' do
        let(:params) do
          {
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
        it { is_expected.to contain_file(conf_file).with_content(%r{password: abc123}) }

        context 'with default parameters' do
          it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{dbname: postgres}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{port: 5432}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{username: datadog}) }
          it { is_expected.to contain_file(conf_file).without_content(%r{^\s*use_psycopg2: }) }
          it { is_expected.to contain_file(conf_file).with_content(%r{collect_function_metrics: false}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{collect_count_metrics: false}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{collect_activity_metrics: false}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{collect_database_size_metrics: false}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{collect_default_database: false}) }
          it { is_expected.to contain_file(conf_file).without_content(%r{tags: }) }
          it { is_expected.to contain_file(conf_file).without_content(%r{^[^#]*relations: }) }
        end

        context 'with extra metrics collection' do
          let(:params) do
            {
              password: 'abc123',
              collect_function_metrics: true,
              collect_count_metrics: true,
              collect_activity_metrics: true,
              collect_database_size_metrics: true,
              collect_default_database: true,
            }
          end

          it {
            is_expected.to contain_file(conf_file)
              .with_content(%r{collect_function_metrics: true})
              .with_content(%r{collect_count_metrics: true})
              .with_content(%r{collect_activity_metrics: true})
              .with_content(%r{collect_database_size_metrics: true})
              .with_content(%r{collect_default_database: true})
          }
        end

        context 'with use_psycopg2' do
          let(:params) do
            {
              use_psycopg2: true,
              password: 'abc123',
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{use_psycopg2: true}) }
        end

        context 'with parameters set' do
          let(:params) do
            {
              host: 'postgres1',
              dbname: 'cats',
              port: 4142,
              username: 'monitoring',
              password: 'abc123',
              tags: ['foo', 'bar', 'baz'],
              tables: ['furry', 'fuzzy', 'funky'],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{host: postgres1}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{dbname: cats}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{port: 4142}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{username: monitoring}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*tags:\s+- foo\s+- bar\s+- baz}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*relations:\s+- furry\s+- fuzzy\s+- funky}) }

          context 'with custom metric query missing %s' do
            let(:params) do
              {
                host: 'postgres1',
                dbname: 'cats',
                port: 4142,
                username: 'monitoring',
                password: 'abc123',
                custom_metrics: {
                  'query_is_missing_%s' => {
                    'query' => 'select * from fuzz',
                    'metrics' => {},
                  },
                },
              }
            end

            it do
              expect {
                is_expected.to compile
              }.to raise_error(%r{custom_metrics require %s for metric substitution})
            end
          end

          context 'with custom metric query' do
            let(:params) do
              {
                host: 'postgres1',
                dbname: 'cats',
                port: 4142,
                username: 'monitoring',
                password: 'abc123',
                custom_metrics: {
                  'foo_gooo_bar_query' => {
                    'query' => 'select foo, %s from bar',
                    'metrics' => {
                      'gooo' => ['custom_metric.tag.gooo', 'GAUGE'],
                    },
                    'descriptors' => [['foo', 'custom_metric.tag.foo']],
                  },
                },
              }
            end

            it { is_expected.to compile }
            it { is_expected.to contain_file(conf_file).with_content(%r{^[^#]*custom_metrics:}) }
            it { is_expected.to contain_file(conf_file).with_content(%r{\s+query:\s*['"]?select foo, %s from bar['"]?}) }
            it { is_expected.to contain_file(conf_file).with_content(%r{\s+metrics:}) }
            it { is_expected.to contain_file(conf_file).with_content(%r{\s+"gooo":\s+\[custom_metric.tag.gooo, GAUGE\]}) }
            it { is_expected.to contain_file(conf_file).with_content(%r{\s+query.*[\r\n]+\s+relation:\s*false}) }
            it { is_expected.to contain_file(conf_file).with_content(%r{\s+descriptors.*[\r\n]+\s+-\s+\[foo, custom_metric.tag.foo\]}) }
          end
        end
      end
    end
  end
end
