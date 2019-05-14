require 'spec_helper'

describe 'datadog_agent::integrations::postgres' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/postgres.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/postgres.d/conf.yaml" }
      end

      context 'with default parameters' do
        it { should compile }
      end

      context 'with password set' do
        let(:params) {{
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
        it { should contain_file(conf_file).with_content(/password: abc123/) }

        context 'with default parameters' do
          it { should contain_file(conf_file).with_content(%r{host: localhost}) }
          it { should contain_file(conf_file).with_content(%r{dbname: postgres}) }
          it { should contain_file(conf_file).with_content(%r{port: 5432}) }
          it { should contain_file(conf_file).with_content(%r{username: datadog}) }
          it { should contain_file(conf_file).without_content(%r{^\s*use_psycopg2: }) }
          it { should contain_file(conf_file).with_content(%r{collect_function_metrics: false}) }
          it { should contain_file(conf_file).with_content(%r{collect_count_metrics: false}) }
          it { should contain_file(conf_file).with_content(%r{collect_activity_metrics: false}) }
          it { should contain_file(conf_file).with_content(%r{collect_database_size_metrics: false}) }
          it { should contain_file(conf_file).with_content(%r{collect_default_database: false}) }
          it { should contain_file(conf_file).without_content(%r{tags: })}
          it { should contain_file(conf_file).without_content(%r{^[^#]*relations: }) }
        end

        context 'with extra metrics collection is_agent5' do
          let(:params) {{
            password: 'abc123',
            collect_function_metrics: true,
            collect_count_metrics: true,
            collect_activity_metrics: true,
            collect_database_size_metrics: true,
            collect_default_database: true,
          }}
          it {
            should contain_file(conf_file)
              .with_content(%r{collect_function_metrics: true})
              .with_content(%r{collect_count_metrics: true})
              .with_content(%r{collect_activity_metrics: true})
              .with_content(%r{collect_database_size_metrics: true})
              .with_content(%r{collect_default_database: true})
          }
        end

        context 'with use_psycopg2 is_agent5' do
          let(:params) {{
            use_psycopg2: true,
            password: 'abc123',
          }}
          it { should contain_file(conf_file).with_content(%r{use_psycopg2: true}) }
        end

        context 'with parameters set' do
          let(:params) {{
            host: 'postgres1',
            dbname: 'cats',
            port: 4142,
            username: 'monitoring',
            password: 'abc123',
            tags: %w{foo bar baz},
            tables: %w{furry fuzzy funky}
          }}
          it { should contain_file(conf_file).with_content(%r{host: postgres1}) }
          it { should contain_file(conf_file).with_content(%r{dbname: cats}) }
          it { should contain_file(conf_file).with_content(%r{port: 4142}) }
          it { should contain_file(conf_file).with_content(%r{username: monitoring}) }
          it { should contain_file(conf_file).with_content(%r{^[^#]*tags:\s+- foo\s+- bar\s+- baz}) }
          it { should contain_file(conf_file).with_content(%r{^[^#]*relations:\s+- furry\s+- fuzzy\s+- funky}) }

          context 'with custom metric query missing %s' do
            let(:params) {{
              host: 'postgres1',
              dbname: 'cats',
              port: 4142,
              username: 'monitoring',
              password: 'abc123',
              custom_metrics: {
                'query_is_missing_%s' => {
                  'query' => 'select * from fuzz',
                  'metrics' => { },
                }
              }
            }}
            it do
              expect {
                is_expected.to compile
              }.to raise_error(/custom_metrics require %s for metric substitution/)
            end
          end

          context 'with custom metric query' do
            let(:params) {{
              host: 'postgres1',
              dbname: 'cats',
              port: 4142,
              username: 'monitoring',
              password: 'abc123',
              custom_metrics: {
                'foo_gooo_bar_query' => {
                  'query' => 'select foo, %s from bar',
                  'metrics' => {
                    "gooo" => ["custom_metric.tag.gooo", "GAUGE"]
                  },
                  'descriptors' => [["foo", "custom_metric.tag.foo"]]
                }
              }
            }}
            it { is_expected.to compile }
            it { should contain_file(conf_file).with_content(%r{^[^#]*custom_metrics:}) }
            it { should contain_file(conf_file).with_content(%r{\s+query:\s*['"]?select foo, %s from bar['"]?}) }
            it { should contain_file(conf_file).with_content(%r{\s+metrics:}) }
            it { should contain_file(conf_file).with_content(%r{\s+"gooo":\s+\[custom_metric.tag.gooo, GAUGE\]}) }
            it { should contain_file(conf_file).with_content(%r{\s+query.*\n\s+relation:\s*false}) }
            it { should contain_file(conf_file).with_content(%r{\s+descriptors.*\n\s+-\s+\[foo, custom_metric.tag.foo\]}) }
          end
        end
      end
    end
  end
end
