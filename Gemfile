source "https://rubygems.org"

# Puppet 4.10.2 is the minimum version we support on Windows due to https://tickets.puppetlabs.com/browse/PUP-7383
# On Linux we support down to 4.6
gem "puppet", "~> #{ENV.fetch('PUPPET_VERSION', '4.10.2')}"

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem "rake", "~> 12.3.3"                                          if RUBY_VERSION < '2.6.0' # last version for ruby < 2.6
  gem "xmlrpc"                                                     if RUBY_VERSION >= '2.3'
  gem "ruby-pwsh", '~> 0.3.0',                                     platforms: [:mswin, :mingw, :x64_mingw]
  gem "fast_gettext", '1.1.0',                                     require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.1.0')
  gem "fast_gettext",                                              require: false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.1.0')
  gem "json_pure", '<= 2.0.1',                                     require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.0.0')
  gem "json", '= 1.8.1',                                           require: false if Gem::Version.new(RUBY_VERSION.dup) == Gem::Version.new('2.1.9')
  gem "json", '= 2.0.4',                                           require: false if Gem::Requirement.create('~> 2.4.2').satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.1.0',                                           require: false if Gem::Requirement.create(['>= 2.5.0', '< 2.7.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "rb-readline", '= 0.5.5',                                    require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "librarian-puppet"
  gem "kitchen-puppet"
  gem "kitchen-vagrant"
  gem "kitchen-docker"
  gem "kitchen-verifier-serverspec"

  if RUBY_VERSION >= '2.3'
    gem "test-kitchen"
    gem "puppet-module-posix-default-r#{minor_version}", '~> 0.3', require: false, platforms: [:ruby]
    gem "puppet-module-posix-dev-r#{minor_version}", '~> 0.3',     require: false, platforms: [:ruby]
    gem "puppet-module-win-default-r#{minor_version}", '~> 0.3',   require: false, platforms: [:mswin, :mingw, :x64_mingw]
    gem "puppet-module-win-dev-r#{minor_version}", '~> 0.3',       require: false, platforms: [:mswin, :mingw, :x64_mingw]
  else
    gem "test-kitchen", '~> 1.16.0'
    gem "puppetlabs_spec_helper", "~> 2.14.1"
    gem "puppet-lint", "~> 2.4.2"
    gem "metadata-json-lint", "~> 1.2.2"
    gem "puppet-syntax", "~> 2.5.0"
    gem "rspec-puppet", "~> 2.6.9"
    gem "rubocop", "~> 0.49.1"
    gem "rubocop-i18n", "~> 1.2.0"
    gem "rubocop-rspec", "~> 1.16.0"
    gem "artifactory", "~> 2.8.2"
  end
end
