require 'spec_helper'

describe "datadog_agent::integration" do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{enabled}}" }
      if enabled
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end

      let (:title) { "test" }
      let(:facts) do
        {
          operatingsystem: 'CentOS',
          osfamily: 'redhat'
        }
      end
      let (:params) {{
          :instances => [
              { 'one' => "two" }
          ]
      }}
      it { should compile }
      it { should contain_file("#{conf_dir}/test.yaml").with_content(/init_config: /) }
      gem_spec = Gem.loaded_specs['puppet']
      if gem_spec.version >= Gem::Version.new('4.0.0')
        it { should contain_file("#{conf_dir}/test.yaml").with_content(/---\ninit_config: \ninstances:\n- one: two\n/) }
      else
        it { should contain_file("#{conf_dir}/test.yaml").with_content(/--- \n  init_config: \n  instances: \n    - one: two/) }
      end
      it { should contain_file("#{conf_dir}/test.yaml").that_notifies("Service[datadog-agent]") }
    end
  end
end
