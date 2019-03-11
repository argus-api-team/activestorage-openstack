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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either
  # set the 'allowed_push_host' to allow pushing to a single host or
  # delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ''
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir[
    '{app,config,db,lib}/**/*',
    'MIT-LICENSE',
    'Rakefile',
    'README.md'
  ]

  spec.add_dependency 'marcel'
  spec.add_dependency 'rails', '~> 6.0.0.beta2'
  spec.add_dependency 'tzinfo-data'
  spec.add_dependency 'zeitwerk'

  spec.add_development_dependency 'rspec-rails', '~> 3.8'
  spec.add_development_dependency 'sqlite3', '~> 1.3.6'
end
