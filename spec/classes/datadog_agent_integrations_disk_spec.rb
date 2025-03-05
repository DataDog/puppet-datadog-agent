require 'spec_helper'

describe 'datadog_agent::integrations::disk' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      let(:yaml_conf) do
        <<-HEREDOC
### MANAGED BY PUPPET

init_config:

instances:
  - use_mount: false
      HEREDOC
      end

      conf_file = "#{CONF_DIR}/disk.d/conf.yaml"

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with_content(yaml_conf).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'compile errors for incorrect values' do
        let(:params) do
          {
            use_mount: 'heaps',
          }
        end

        it do
          expect { is_expected.to compile }.to raise_error(%r{error\s+during\s+compilation})
        end
      end

      context 'we handle strings and arrays the same' do
        let(:params) do
          {
            use_mount: true,
            excluded_filesystems: ['tmpfs', 'dev'],
            excluded_disks: '/dev/sda1',
            excluded_disk_re: '/dev/sdb.*',
            excluded_mountpoint_re: '/mnt/other.*',
            all_partitions: true,
            tag_by_filesystem: false,
          }
        end
        let(:yaml_conf) do
          <<-HEREDOC
### MANAGED BY PUPPET

init_config:

instances:
  - use_mount: true
    excluded_filesystems:
      - tmpfs
      - dev
    excluded_disks:
      - /dev/sda1
    excluded_disk_re: /dev/sdb.*
    excluded_mountpoint_re: /mnt/other.*
    all_partitions: true
    tag_by_filesystem: false
        HEREDOC
        end

        it { is_expected.to contain_file(conf_file).with_content(yaml_conf) }
      end

      context 'we handle new disk configuration option' do
        let(:params) do
          {
            use_mount: true,
            filesystem_blacklist: ['tmpfs', 'dev'],
            device_blacklist: ['/dev/sda1'],
            mountpoint_blacklist: ['/mnt/foo'],
            filesystem_whitelist: ['ext4', 'hdfs', 'reiserfs'],
            device_whitelist: ['/dev/sdc1', '/dev/sdc2', '/dev/sdd2'],
            mountpoint_whitelist: ['/mnt/logs', '/mnt/builds'],
            all_partitions: true,
            tag_by_filesystem: false,
          }
        end
        let(:yaml_conf) do
          <<-HEREDOC
### MANAGED BY PUPPET

init_config:

instances:
  - use_mount: true
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
    all_partitions: true
    tag_by_filesystem: false
        HEREDOC
        end

        it { is_expected.to contain_file(conf_file).with_content(yaml_conf) }
      end

      context 'agent_version >= 7.24.0 disk configuration option' do
        let(:params) do
          {
            use_mount: true,
            filesystem_exclude: ['tmpfs', 'dev'],
            device_exclude: ['/dev/sda1'],
            mountpoint_exclude: ['/mnt/foo'],
            filesystem_include: ['ext4', 'hdfs', 'reiserfs'],
            device_include: ['/dev/sdc1', '/dev/sdc2', '/dev/sdd2'],
            mountpoint_include: ['/mnt/logs', '/mnt/builds'],
            all_partitions: true,
            tag_by_filesystem: false,
          }
        end
        let(:yaml_conf) do
          <<-HEREDOC
### MANAGED BY PUPPET

init_config:

instances:
  - use_mount: true
    file_system_exclude:
      - tmpfs
      - dev
    device_exclude:
      - /dev/sda1
    mount_point_exclude:
      - /mnt/foo
    file_system_include:
      - ext4
      - hdfs
      - reiserfs
    device_include:
      - /dev/sdc1
      - /dev/sdc2
      - /dev/sdd2
    mount_point_include:
      - /mnt/logs
      - /mnt/builds
    all_partitions: true
    tag_by_filesystem: false
        HEREDOC
        end

        it { is_expected.to contain_file(conf_file).with_content(yaml_conf) }
      end
    end
  end
end
