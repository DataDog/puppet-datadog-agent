require 'spec_helper'

describe 'datadog_agent::integrations::php_fpm' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/php_fpm.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(/status_url: http:\/\/localhost\/status/) }
    it { should contain_file(conf_file).with_content(/ping_url: http:\/\/localhost\/ping/) }
  end

  context 'with parameters set' do
    let(:params) {{
      status_url: 'http://localhost/fpm_status',
      ping_url: 'http://localhost/fpm_ping',
    }}
    it { should contain_file(conf_file).with_content(/status_url: http:\/\/localhost\/fpm_status/) }
    it { should contain_file(conf_file).with_content(/ping_url: http:\/\/localhost\/fpm_ping/) }
  end
end
