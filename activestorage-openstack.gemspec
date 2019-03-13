# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'active_storage/openstack/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.platform    = Gem::Platform::RUBY
  spec.name        = 'activestorage_openstack'
  spec.version     = ActiveStorage::Openstack::VERSION
  spec.authors     = ['Mickael Palma']
  spec.email       = ['mpalma@largus.fr']
  spec.homepage    = 'https://github.com/mickael-palma-argus/activestorage-openstack'
  spec.summary     = 'OpenStack ActiveStorage service.'
  spec.description = 'OpenStack ActiveStorage service without dependencies.'
  spec.license     = 'MIT'

  spec.files = Dir[
    '{app,config,db,lib}/**/*',
    'MIT-LICENSE',
    'Rakefile',
    'README.md'
  ]

  spec.add_runtime_dependency 'marcel', '~> 0.3'
  spec.add_runtime_dependency 'rails', '~> 6.0.0.beta2'
  spec.add_runtime_dependency 'tzinfo-data', '~> 1.2'
  spec.add_runtime_dependency 'zeitwerk', '~> 1.3'

  spec.add_development_dependency 'rspec-rails', '~> 3.8'
  spec.add_development_dependency 'sqlite3', '~> 1.3.6'
end
