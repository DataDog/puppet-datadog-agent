require 'spec_helper'

describe 'datadog_agent::integrations::cacti' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/cacti.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/cacti.d/conf.yaml" }
      end

      context 'with default parameters' do
        it { should compile }
      end

      context 'with parameters set' do
        let(:params) {{
          mysql_host: 'localhost',
          mysql_user: 'foo',
          mysql_password: 'bar',
          rrd_path: 'path',
        }}
        it { should contain_file(conf_file).with_content(/mysql_host: localhost/) }
        it { should contain_file(conf_file).with_content(/mysql_user: foo/) }
        it { should contain_file(conf_file).with_content(/mysql_password: bar/) }
        it { should contain_file(conf_file).with_content(/rrd_path: path/) }
      end
    end
  end
end
