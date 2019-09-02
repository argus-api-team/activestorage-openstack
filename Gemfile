# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.4'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development, :test do
  gem 'awesome_print'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'coderay'
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-reek'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'rails-controller-testing'
  gem 'reek'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock'
end
