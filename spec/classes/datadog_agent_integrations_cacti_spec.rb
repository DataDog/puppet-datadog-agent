require 'spec_helper'

describe 'datadog_agent::integrations::cacti' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/cacti.yaml'
                  else
                    "#{CONF_DIR}/cacti.d/conf.yaml"
                  end

      context 'with default parameters' do
        it { is_expected.to compile }
      end

      context 'with parameters set' do
        let(:params) do
          {
            mysql_host: 'localhost',
            mysql_user: 'foo',
            mysql_password: 'bar',
            rrd_path: 'path',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{mysql_host: localhost}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{mysql_user: foo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{mysql_password: bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{rrd_path: path}) }
      end
    end
  end
end
