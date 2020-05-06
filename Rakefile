require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'puppet-lint/tasks/puppet-lint'
require 'rubocop/rake_task'
require 'kitchen/rake_tasks'

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc "Run syntax, lint, and spec tests."
task :test => [
  'syntax',
  'lint',
  'metadata_lint',
  'check:symlinks',
  'check:git_ignore',
  'check:dot_underscore',
  'rubocop',
  'spec',
]

desc 'Run Kitchen tests using CircleCI parallelism mode, split by worker'
task :circle do
  def kitchen_config
    raw_config = Kitchen::Loader::YAML.new(
      local_config: ENV['KITCHEN_LOCAL_YAML']
    )

    Kitchen::Config.new(loader: raw_config)
  end

  def total_workers
    ENV.fetch('CIRCLE_NODE_TOTAL', 1).to_i
  end

  def current_worker
    ENV.fetch('CIRCLE_NODE_INDEX', 0).to_i
  end

  def command
    kitchen_config.instances.sort_by(&:name).each_with_object([]).with_index do |(instance, commands), index|
      next unless index % total_workers == current_worker

      commands << "kitchen test #{instance.name}"
    end.join(' && ')
  end

  sh command unless command.empty?
end
