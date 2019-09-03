require 'spec_helper'

describe 'datadog_agent::integrations::disk' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/disk.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/disk.d/conf.yaml" }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to  contain_file(conf_file).with_content(
        %r{\s+use_mount:\s+no[\r]*$}
      ).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_PROTECTED_FILE,
      )}
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'compile errors for incorrect values' do
        let(:params) {{ use_mount: 'heaps' }}
        it do
          expect { is_expected.to compile }.to raise_error(/error\s+during\s+compilation/)
        end
      end

      context 'we handle strings and arrays the same' do
        let(:params) {{
          use_mount: 'yes',
          excluded_filesystems: [ 'tmpfs', 'dev' ],
          excluded_disks: '/dev/sda1',
          excluded_disk_re: '/dev/sdb.*',
          excluded_mountpoint_re: '/mnt/other.*',
          all_partitions: 'yes',
          tag_by_filesystem: 'no'
        }}
        let(:yaml_conf) {
           <<-HEREDOC
### MANAGED BY PUPPET

init_config:

instances:
  - use_mount: yes
    excluded_filesystems:
      - tmpfs
      - dev
    excluded_disks:
      - /dev/sda1
    excluded_disk_re: /dev/sdb.*
    excluded_mountpoint_re: /mnt/other.*
    all_partitions: yes
    tag_by_filesystem: no
        HEREDOC
         }
        it { 
          if RSpec::Support::OS.windows?
            yaml_conf.gsub!(/\n/, "\r\n")
          end  
          is_expected.to contain_file(conf_file).with_content(yaml_conf) 
        }
      end

      context 'we handle new disk configuration option' do
        let(:params) {{
          use_mount: 'yes',
          filesystem_blacklist: ['tmpfs', 'dev'],
          device_blacklist: ['/dev/sda1'],
          mountpoint_blacklist: ['/mnt/foo'],
          filesystem_whitelist: ['ext4', 'hdfs', 'reiserfs'],
          device_whitelist: ['/dev/sdc1', '/dev/sdc2', '/dev/sdd2'],
          mountpoint_whitelist: ['/mnt/logs', '/mnt/builds'],
          all_partitions: 'yes',
          tag_by_filesystem: 'no'
        }}
        let(:yaml_conf) {
           <<-HEREDOC
### MANAGED BY PUPPET

init_config:

instances:
  - use_mount: yes
    file_system_blacklist:
      - tmpfs
      - dev
    device_blacklist:
      - /dev/sda1
    mount_point_blacklist:
      - /mnt/foo
    file_system_whitelist:
      - ext4
      - hdfs
      - reiserfs
    device_whitelist:
      - /dev/sdc1
      - /dev/sdc2
      - /dev/sdd2
    mount_point_whitelist:
      - /mnt/logs
      - /mnt/builds
    all_partitions: yes
    tag_by_filesystem: no
        HEREDOC
         }
        it {
          if RSpec::Support::OS.windows?
            yaml_conf.gsub!(/\n/, "\r\n")
          end
          is_expected.to contain_file(conf_file).with_content(yaml_conf) 
        }
      end
    end
  end
end
