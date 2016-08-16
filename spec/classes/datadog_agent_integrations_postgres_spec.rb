require 'spec_helper'

describe 'datadog_agent::integrations::postgres' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/postgres.yaml" }

  context 'with default parameters' do
    it { should_not compile }
  end

  context 'with password set' do
    let(:params) {{
      password: 'abc123',
    }}

    it { is_expected.to contain_class("datadog_agent::params")  }

    it { should contain_file(conf_file).with(
      owner: dd_user,
      group: dd_group,
      mode: '0600',
    )}

    it { is_expected.to contain_file(conf_file).with(
        'require' => 'Class[Datadog_agent]',
        'notify'  => "Service[#{dd_service}]",
        'content' => /password: abc123/,
    )}

    context 'with default parameters' do
      it { should contain_file(conf_file).with_content(%r{host: localhost}) }
      it { should contain_file(conf_file).with_content(%r{dbname: postgres}) }
      it { should contain_file(conf_file).with_content(%r{port: 5432}) }
      it { should contain_file(conf_file).with_content(%r{username: datadog}) }
      it { should contain_file(conf_file).without_content(%r{tags: })}
      it { should contain_file(conf_file).without_content(%r{^[^#]*relations: }) }
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
    end
  end

end
