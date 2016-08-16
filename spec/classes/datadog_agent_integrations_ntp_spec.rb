require 'spec_helper'

describe 'datadog_agent::integrations::ntp' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/ntp.yaml" }

  it { is_expected.to contain_class("datadog_agent::params")  }

  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}

  it { is_expected.to contain_file(conf_file).with(
    'require' => 'Class[Datadog_agent]',
    'notify'  => "Service[#{dd_service}]",
  )}

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(/offset_threshold: 60/) }
  end

  context 'with parameters set' do
    let(:params) {{
      offset_threshold: 42,
    }}
    it { should contain_file(conf_file).with_content(/offset_threshold: 42/) }
  end


end
