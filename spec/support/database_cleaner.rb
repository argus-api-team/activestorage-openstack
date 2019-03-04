# frozen_string_literal: true

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:deletion)
  end

  config.around(:each) do |example| # rubocop:disable RSpec/HookArgument
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
