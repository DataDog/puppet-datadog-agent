require 'spec_helper'

describe 'datadog_agent::integrations::ceph' do
  if RSpec::Support::OS.windows?
    # Check not supported on Windows
    return
  end

  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/ceph.yaml'
                  else
                    "#{CONF_DIR}/ceph.d/conf.yaml"
                  end

      sudo_conf_file = '/etc/sudoers.d/datadog_ceph'

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
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- name:ceph_cluster\s*?[^-]}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^\s*ceph_cmd:\s*/usr/bin/ceph\s*?[^-]}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^\s*use_sudo:\sTrue[\r]*$}) }
        it { is_expected.to contain_file(sudo_conf_file).with_content(%r{^dd-agent\sALL=.*NOPASSWD:/usr/bin/ceph[\r]*$}) }
      end

      context 'with specified tag' do
        let(:params) do
          {
            tags: ['name:my_ceph_cluster'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- name:my_ceph_cluster\s*?[^-]}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^\s*ceph_cmd:\s*/usr/bin/ceph\s*?[^-]}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^\s*use_sudo:\sTrue[\r]*$}) }
        it { is_expected.to contain_file(sudo_conf_file).with_content(%r{^dd-agent\sALL=.*NOPASSWD:/usr/bin/ceph[\r]*$}) }
      end

      context 'with specified ceph_cmd' do
        let(:params) do
          {
            ceph_cmd: '/usr/local/myceph',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- name:ceph_cluster\s*?[^-]}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^\s*ceph_cmd:\s*/usr/local/myceph\s*?[^-]}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{^\s*use_sudo:\sTrue[\r]*$}) }
        it { is_expected.to contain_file(sudo_conf_file).with_content(%r{^dd-agent\sALL=.*NOPASSWD:/usr/bin/ceph[\r]*$}) }
      end
    end
  end
end
