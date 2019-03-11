# frozen_string_literal: true

Rails.application.config.x.openstack = Rails.application
                                            .config_for(:openstack)
                                            .symbolize_keys
