require 'spec_helper'

describe 'datadog_agent::integrations::disk' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/disk.yaml" }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to  contain_file(conf_file).with_content(
    %r{\s+use_mount:\s+no$}
  ).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { is_expected.to contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { is_expected.to contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'compile errors for incorrect values' do
    let(:params) {{ use_mount: 'heaps' }}
    it do
      expect { is_expected.to compile }.to raise_error(/Evaluation Error/)
    end
  end

  context 'we handle strings and arrays the same' do
    let(:params) {{
      use_mount: 'yes',
      excluded_filesystems: [ 'tmpfs', 'dev' ],
      excluded_disks: '/dev/sda1'
    }}
    it { is_expected.to contain_file(conf_file).with_content(%r{\s+-\s+tmpfs\n\s+-\s+dev$}) }
  end

end
