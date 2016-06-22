source "https://rubygems.org"

group :test do
  gem "syck"
  gem "safe_yaml", "~> 1.0.4"
  gem "listen", "~> 3.0.0"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.2.0'
  gem "puppet-lint"
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "rake"
  gem "rspec-puppet", '2.2.0'
end

group :development do
  gem "beaker"
  gem "beaker-rspec"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
