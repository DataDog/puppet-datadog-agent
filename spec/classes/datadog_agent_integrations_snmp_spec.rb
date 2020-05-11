require 'spec_helper'

describe 'datadog_agent::integrations::snmp' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |agent_major_version|
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      if agent_major_version == 5
        let(:conf_file) { '/etc/dd-agent/conf.d/snmp.yaml' }
      else
        let(:conf_file) { "#{CONF_DIR}/snmp.d/conf.yaml" }
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

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).without_content(%r{ignore_nonincreasing_oid}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            ignore_nonincreasing_oid: true,
            instances: {
              ip_address: 'localhost',
              port: 161,
              community_string: 'public',
              tags: [
                'optional_tag_1',
              ],
              metrics: [
                {
                  MIB: 'IF-MIB',
                  table: 'ifTable',
                  symbols: [
                    'ifInOctets',
                    'ifOutOctets',
                  ],
                  metric_tags: [
                    {
                      tag: 'interface',
                      column: 'ifDescr',
                    },
                    {
                      tag: 'interface_index',
                      column: 'ifIndex',
                    },
                  ],
                },
              ],
            },
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{ignore_nonincreasing_oid: true}) }

        it do
          content = get_from_catalogue('file', conf_file, 'content')
          yaml = YAML.safe_load(content)
          expect(yaml).to include('init_config')
          expect(yaml['init_config']).to include('ignore_nonincreasing_oid')
          expect(yaml).to include('instances')
          expect(yaml['instances']).to include('tags')
          expect(yaml['instances']['tags']).to include('optional_tag_1')
        end
      end
    end
  end
end
