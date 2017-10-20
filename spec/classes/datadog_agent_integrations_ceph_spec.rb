require 'spec_helper'

describe 'datadog_agent::integrations::ceph' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/ceph.yaml" }
  let(:sudo_conf_file) { '/etc/sudoers.d/datadog_ceph' }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(/tags:\s+- name:ceph_cluster\s*?[^-]/m) }
    it { should contain_file(conf_file).with_content(/^\s*ceph_cmd:\s*\/usr\/bin\/ceph\s*?[^-]/m) }
    it { should contain_file(conf_file).with_content(/^\s*use_sudo:\sTrue$/) }
    it { should contain_file(sudo_conf_file).with_content(/^dd-agent\sALL=.*NOPASSWD:\/usr\/bin\/ceph$/) }
  end

  context 'with specified tag' do
    let(:params) {{
      tags: ['name:my_ceph_cluster'],
    }}
    it { should contain_file(conf_file).with_content(/tags:\s+- name:my_ceph_cluster\s*?[^-]/m) }
    it { should contain_file(conf_file).with_content(/^\s*ceph_cmd:\s*\/usr\/bin\/ceph\s*?[^-]/m) }
    it { should contain_file(conf_file).with_content(/^\s*use_sudo:\sTrue$/) }
    it { should contain_file(sudo_conf_file).with_content(/^dd-agent\sALL=.*NOPASSWD:\/usr\/bin\/ceph$/) }
  end

  context 'with specified ceph_cmd' do
    let(:params) {{
      ceph_cmd: '/usr/local/myceph',
    }}
    it { should contain_file(conf_file).with_content(/tags:\s+- name:ceph_cluster\s*?[^-]/m) }
    it { should contain_file(conf_file).with_content(/^\s*ceph_cmd:\s*\/usr\/local\/myceph\s*?[^-]/m) }
    it { should contain_file(conf_file).with_content(/^\s*use_sudo:\sTrue$/) }
    it { should contain_file(sudo_conf_file).with_content(/^dd-agent\sALL=.*NOPASSWD:\/usr\/bin\/ceph$/) }
  end

end
