source "https://rubygems.org"

group :test do
  gem "rb-inotify", '< 0.10.0' if RUBY_VERSION < '2.2.0'
  gem "public_suffix", "~> 3.0.0"
  gem "listen", "~> 3.0.0"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.6.2'
  gem "puppet-lint", "~> 2.3.6"
  gem "puppet-syntax", "~> 2.5.0"
  gem "puppetlabs_spec_helper", "~> 2.14.1"
  gem "jwt", "~> 1.5.6"
  gem "rake"
  gem "rspec-puppet", '2.6.9'
  gem 'rspec-puppet-facts', '~> 1.7', :require => false
end

group :development do
  gem "fog-openstack", "0.1.25" if RUBY_VERSION < '2.2.0'
  gem "guard-rake"
  gem "mocha", "~> 1.9.0"
  gem "rspec-core", "~> 3.8.2"
  gem "rspec-expectations", "~> 3.8.4"
  gem "rspec-mocks", "~> 3.8.1"
  gem "puppet-blacksmith", "~> 4.1.2"
  gem "xmlrpc" if RUBY_VERSION >= '2.3'
end
