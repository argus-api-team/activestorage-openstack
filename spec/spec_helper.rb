# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('dummy/config/environment', __dir__)

ActiveRecord::Migrator.migrations_paths = [
  File.expand_path('dummy/db/migrate', __dir__)
]

if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

require 'rspec/rails'

Dir["#{Dir.pwd}/spec/support/**/*.rb"].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => exception
  puts exception.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = File.expand_path('fixtures', __dir__)
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
