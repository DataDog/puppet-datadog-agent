source "https://rubygems.org"

group :test do
  gem "syck"
  gem "safe_yaml", "~> 1.0.4"
  gem "hiera-eyaml", "~> 2.1.0"
  gem "listen", "~> 3.0.0"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.2.0'
  gem "puppet-lint"
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "rake"
  gem "rspec-puppet", '2.3.2'
end

group :development do
  gem "beaker-rspec"
  gem "beaker", '2.51.0'
  gem "guard-rake"
  gem "nokogiri", "~> 1.6.0"
  gem "puppet-blacksmith"
  gem "xmlrpc" if RUBY_VERSION >= '2.3'
end
