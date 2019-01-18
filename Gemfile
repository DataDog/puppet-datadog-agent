source "https://rubygems.org"

group :test do
  gem "rb-inotify", '< 0.10.0' if RUBY_VERSION < '2.2.0'
  gem "public_suffix", "~> 3.0.0"
  gem "listen", "~> 3.0.0"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 5.5.1'
  gem "puppet-lint"
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "jwt", "~> 1.5.6"
  gem "rake"
  gem "rspec-puppet", '2.6.9'
  gem 'rspec-puppet-facts', '~> 1.7', :require => false
end

group :development do
  gem "fog-openstack", "0.1.25" if RUBY_VERSION < '2.2.0'
  gem "beaker-rspec"
  gem "beaker", '3.31.0'
  gem "guard-rake"
  gem "nokogiri", "~> 1.8.2"
  gem "puppet-blacksmith"
  gem "xmlrpc" if RUBY_VERSION >= '2.3'
end
