source ENV['GEM_SOURCE'] || 'https://rubygems.org'

ruby_version = Gem::Version.new(RUBY_VERSION.dup)

def location_for(place_or_version, fake_version = nil)
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

group :development do
  gem "json", '= 2.1.0',                         require: false if Gem::Requirement.create(['>= 2.5.0', '< 2.7.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.3.0',                         require: false if Gem::Requirement.create(['>= 2.7.0', '< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.5.1',                         require: false if Gem::Requirement.create(['>= 3.0.0', '< 3.0.5']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.6.1',                         require: false if Gem::Requirement.create(['>= 3.1.0', '< 3.1.3']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.6.3',                         require: false if Gem::Requirement.create(['>= 3.2.0', '< 4.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "racc", '~> 1.4.0',                        require: false if Gem::Requirement.create(['>= 2.7.0', '< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "deep_merge", '~> 1.2.2',                  require: false
  gem "parallel_tests", '= 3.12.1',              require: false
  gem "pry", '~> 0.10',                          require: false
  gem "simplecov-console", '~> 0.9',             require: false
  gem "puppet-debugger", '~> 1.0',               require: false
  gem "rb-readline", '= 0.5.5',                  require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "bcrypt_pbkdf", '= 1.0.1',                 require: false
  gem "kitchen-puppet"
  gem "kitchen-docker", '~> 3.0.0',              require: false
  gem "kitchen-verifier-serverspec"
  gem "rexml", '~> 3.4.0',                       require: false
  gem "mixlib-shellout", "~> 2.2.7",             platforms: [:ruby]
  if ruby_version >= Gem::Version.new('2.5') && ruby_version < Gem::Version.new('3.1')
    gem "test-kitchen", '= 3.0.0', platforms: [:ruby]
    gem "rubocop", '~> 1.30',                    require: false
    gem "rubocop-rspec", '= 2.10.0',             require: false
    gem "facterdb", '~> 1.21',                   require: false
    gem "rspec-puppet-facts", '~> 1.10.0',       require: false
    gem "rubocop-performance", '~> 1.11',        require: false
    gem "librarian-puppet", '= 4.0.1'
    gem "io-console", '= 0.5.9',                 require: false
    gem "metadata-json-lint", '~> 3.0.3',        require: false
    gem "voxpupuli-puppet-lint-plugins", '~> 4.0', require: false
    gem "dependency_checker", '= 0.3.0',           require: false
  else
    gem "facterdb", '~> 3.4.0',                      require: false
    gem "test-kitchen", '~> 3.7.0'
    gem "rubocop", '~> 1.50.0',                    require: false
    gem "rubocop-rspec", '= 2.19.0',               require: false
    gem "rspec-puppet-facts", '~> 5.2.0',            require: false
    gem "rubocop-performance", '= 1.16.0',         require: false
    gem "librarian-puppet", '~> 5.0'
    gem "io-console", '= 0.7.2',                   require: false
    gem "metadata-json-lint", '~> 4.0',            require: false
    gem "voxpupuli-puppet-lint-plugins", '~> 5.0', require: false
    gem "dependency_checker", '~> 1.0.0',          require: false
  end
end
group :development, :release_prep do
  if ruby_version >= Gem::Version.new('2.5') && ruby_version < Gem::Version.new('3.1')
    gem "puppetlabs_spec_helper", '~> 5.0.3', require: false
    gem "puppet-blacksmith", '= 6.1.1',       require: false
    gem "puppet-strings", '= 2.9.0',          require: false
  else
    gem "puppetlabs_spec_helper", '~> 8.0', require: false
    gem "puppet-blacksmith", '~> 7.0',      require: false
    gem "puppet-strings", '~> 4.0',         require: false
  end
end
group :system_tests do
  if ruby_version >= Gem::Version.new('2.5') && ruby_version < Gem::Version.new('3.0')
    gem "puppet_litmus", '= 0.0.1',   require: false, platforms: [:ruby, :x64_mingw]
  else
    gem "puppet_litmus", '~> 1.0',    require: false, platforms: [:ruby, :x64_mingw]
  end
  gem "CFPropertyList", '< 3.0.7',    require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "serverspec", '~> 2.41',        require: false
end

puppet_version = ENV['PUPPET_GEM_VERSION']
facter_version = ENV['FACTER_GEM_VERSION']
hiera_version = ENV['HIERA_GEM_VERSION']

gems = {}

gems['puppet'] = location_for(puppet_version)

# If facter or hiera versions have been specified via the environment
# variables

gems['facter'] = location_for(facter_version) if facter_version
gems['hiera'] = location_for(hiera_version) if hiera_version

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
