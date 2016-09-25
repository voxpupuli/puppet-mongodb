# icalvete / smartpuposes
source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.2']

gem 'rake', '~> 10.5.0' if RUBY_VERSION < '1.9.3'
gem 'rake' if RUBY_VERSION >= '1.9.3'
gem 'json', '~> 1.8' if RUBY_VERSION <= '1.9.3'
gem 'json_pure', '~> 1.8' if RUBY_VERSION <= '1.9.3'
gem 'puppet-lint'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper'
gem 'puppet', puppetversion
