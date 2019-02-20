# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  # config.debug_logger = $stderr

  config.filter_sensitive_data('<USERNAME>') do
    Rails.application.credentials.openstack.fetch(:username)
  end

  config.filter_sensitive_data('<API_KEY>') do
    Rails.application.credentials.openstack.fetch(:api_key)
  end

  config.filter_sensitive_data('<TEMPORARY_URL_KEY>') do
    Rails.application.credentials.openstack.fetch(:temporary_url_key)
  end
end
