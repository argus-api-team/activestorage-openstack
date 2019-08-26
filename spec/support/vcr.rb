# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  # config.debug_logger = $stderr

  {
    username: '<USERNAME>',
    api_key: '<API_KEY>',
    temporary_url_key: '<TEMPORARY_URL_KEY>'
  }.each_pair do |key, value|
    config.filter_sensitive_data(value) do
      Rails.application.credentials.openstack.fetch(key)
    end
  end

  # config.before_record do |i|
  #   if i.request.headers.key?('X-Auth-Token')
  #     i.request.headers['X-Auth-Token'] = '__TOKEN__'
  #   end
  # end
end
