# frozen_string_literal: true

require File.expand_path('active_storage/service/openstack_service', __dir__)

# OpenStack
require File.expand_path('active_storage/openstack/client', __dir__)
require File.expand_path('active_storage/openstack/railtie', __dir__)
require File.expand_path('active_storage/openstack/version', __dir__)
require File.expand_path(
  'active_storage/openstack/helpers/https_client', __dir__
)
