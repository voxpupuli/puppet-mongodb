source 'https://rubygems.org'

group :test, :development do
  gem 'rspec-puppet',           :require => false
  gem 'rake',                   :require => false
  gem 'puppetlabs_spec_helper', :require => false
end

if puppetversion = ENV['PUPPET_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
