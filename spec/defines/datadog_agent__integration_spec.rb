require 'spec_helper'

describe "datadog_agent::integration" do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |agent_major_version|
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }
      if agent_major_version == 5
        let(:conf_file) { '/etc/dd-agent/conf.d/test.yaml' }
      else
        let(:conf_dir) { "#{CONF_DIR}/test.d" }
        let(:conf_file) { "#{conf_dir}/conf.yaml" }
      end

      let (:title) { "test" }
      let (:params) {{
          :instances => [
              { 'one' => "two" }
          ]
      }}

      it { should compile }
      if agent_major_version == 5
        it { should contain_file("#{conf_dir}").that_comes_before("File[#{conf_file}]") }
      end
      it { should contain_file("#{conf_file}").with_content(/init_config: /) }
      gem_spec = Gem.loaded_specs['puppet']
      if gem_spec.version >= Gem::Version.new('4.0.0')
        it { should contain_file("#{conf_file}").with_content(/---\ninit_config: \ninstances:\n- one: two\n/) }
      else
        it { should contain_file("#{conf_file}").with_content(/--- \n  init_config: \n  instances: \n    - one: two/) }
      end
      it { should contain_file("#{conf_file}").that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with logs' do
        let(:params) {{
          :instances => [
              { 'one' => "two" }
          ],
          :logs => %w(one two),
        }}

        if gem_spec.version >= Gem::Version.new('4.0.0')
          it { should contain_file(conf_file).with_content(%r{logs:\n- one\n- two}) }
        else
          it { should contain_file(conf_file).with_content(%r{logs:\n  - one\n  - two}) }
        end
      end
    end
  end
end
