# frozen_string_literal: true

require "active_support/core_ext/integer/time"
require Rails.root.join("config/environments/production.rb")

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Full error reports are enabled
  config.consider_all_requests_local = true

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :debug

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  config.action_cable.allowed_request_origins = [ "https://staging.partr.com" ]

  # host url
  Rails.application.routes.default_url_options[:host] = "staging.partr.com"
end
