source "https://rubygems.org"

ruby_version = Gem::Version.new(RUBY_VERSION.dup)

# Each version of Puppet recommends a specific version of Ruby. Try to fetch the Puppet version that
# matches our Ruby (unless PUPPET_VERSION is defined).
matching_puppet_version = ruby_version > Gem::Version.new('2.5') ? (ruby_version > Gem::Version.new('2.7') ? '7.0.0' : '6.0.1') : '4.10.2'
puppet_version = ENV.fetch('PUPPET_VERSION', matching_puppet_version)
gem "puppet", "~> #{puppet_version}"

ruby_version_segments = ruby_version.segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem "rake", "~> 12.3.3"                                          if ruby_version < Gem::Version.new('2.6.0') # last version for ruby < 2.6
  gem "semantic_puppet", '= 1.0.4'
  gem "xmlrpc"                                                      if ruby_version >= Gem::Version.new('2.3')
  gem "concurrent-ruby", '= 1.1.10'                                if Gem::Requirement.create([' >= 6.9.0', '<7.25.0']).satisfied_by?(Gem::Version.new(puppet_version)) # Add this beucause until Puppet 7.25 concurrent-ruby 1.22 break puppet
  gem "ruby-pwsh", '~> 0.3.0',                                     platforms: [:mswin, :mingw, :x64_mingw]
  gem "fast_gettext", '1.1.0',                                     require: false if ruby_version < Gem::Version.new('2.1.0')
  gem "fast_gettext",                                              require: false if ruby_version >= Gem::Version.new('2.1.0')
  gem "json_pure", '<= 2.0.1',                                     require: false if ruby_version < Gem::Version.new('2.0.0')
  gem "json", '= 1.8.1',                                           require: false if ruby_version == Gem::Version.new('2.1.9')
  gem "json", '= 2.0.4',                                           require: false if Gem::Requirement.create('~> 2.4.2').satisfied_by?(ruby_version)
  gem "json", '= 2.1.0',                                           require: false if Gem::Requirement.create(['>= 2.5.0', '< 2.7.0']).satisfied_by?(ruby_version)
  gem "rb-readline", '= 0.5.5',                                    require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "librarian-puppet", '<= 4.0.1'
  gem "kitchen-puppet"
  gem "kitchen-docker"
  gem "kitchen-verifier-serverspec"
  gem "mixlib-shellout", "~> 2.2.7",                               platforms: [:ruby]
  gem "rubocop-i18n", "~> 1.2.0"
  gem "rubocop-rspec", "~> 1.16.0"

  if ruby_version >= Gem::Version.new('2.3')
    gem "test-kitchen", '~> 2.5.4'
    gem "puppet-module-posix-default-r#{minor_version}", require: false, platforms: [:ruby]
    gem "puppet-module-posix-dev-r#{minor_version}",     require: false, platforms: [:ruby]
    gem "puppet-module-win-default-r#{minor_version}",   require: false, platforms: [:mswin, :mingw, :x64_mingw]
    gem "puppet-module-win-dev-r#{minor_version}",       require: false, platforms: [:mswin, :mingw, :x64_mingw]
  else
    gem "test-kitchen", '~> 1.16.0'
    gem "puppetlabs_spec_helper", "~> 2.14.1"
    gem "puppet-lint", "~> 2.4.2"
    gem "metadata-json-lint", "~> 1.2.2"
    gem "puppet-syntax", "~> 2.5.0"
    gem "rspec-puppet", "~> 2.6.9"
    gem "rubocop", "~> 0.49.1"
    gem "artifactory", "~> 2.8.2"
  end
end
