require 'spec_helper'

describe 'datadog_agent::integrations::ceph' do
  
  if RSpec::Support::OS.windows?
    # Check not supported on Windows
    return
  end

  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/ceph.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/ceph.d/conf.yaml" }
      end
      let(:sudo_conf_file) { '/etc/sudoers.d/datadog_ceph' }

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_PROTECTED_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(/tags:\s+- name:ceph_cluster\s*?[^-]/m) }
        it { should contain_file(conf_file).with_content(/^\s*ceph_cmd:\s*\/usr\/bin\/ceph\s*?[^-]/m) }
        it { should contain_file(conf_file).with_content(/^\s*use_sudo:\sTrue[\r]*$/) }
        it { should contain_file(sudo_conf_file).with_content(/^dd-agent\sALL=.*NOPASSWD:\/usr\/bin\/ceph[\r]*$/) }
      end

      context 'with specified tag' do
        let(:params) {{
          tags: ['name:my_ceph_cluster'],
        }}
        it { should contain_file(conf_file).with_content(/tags:\s+- name:my_ceph_cluster\s*?[^-]/m) }
        it { should contain_file(conf_file).with_content(/^\s*ceph_cmd:\s*\/usr\/bin\/ceph\s*?[^-]/m) }
        it { should contain_file(conf_file).with_content(/^\s*use_sudo:\sTrue[\r]*$/) }
        it { should contain_file(sudo_conf_file).with_content(/^dd-agent\sALL=.*NOPASSWD:\/usr\/bin\/ceph[\r]*$/) }
      end

      context 'with specified ceph_cmd' do
        let(:params) {{
          ceph_cmd: '/usr/local/myceph',
        }}
        it { should contain_file(conf_file).with_content(/tags:\s+- name:ceph_cluster\s*?[^-]/m) }
        it { should contain_file(conf_file).with_content(/^\s*ceph_cmd:\s*\/usr\/local\/myceph\s*?[^-]/m) }
        it { should contain_file(conf_file).with_content(/^\s*use_sudo:\sTrue[\r]*$/) }
        it { should contain_file(sudo_conf_file).with_content(/^dd-agent\sALL=.*NOPASSWD:\/usr\/bin\/ceph[\r]*$/) }
      end
    end
  end
end
