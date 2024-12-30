# frozen_string_literal: true

Rails.application.configure do
  case Rails.env
  when "production"
    config.session_store :cookie_store, key: "_partr_session", expire_after: 2.weeks
  when "staging"
    config.session_store :cookie_store, key: "_partr_staging_session", expire_after: 2.weeks
  when "development"
    config.session_store :cookie_store, key: "_partr_dev_session", expire_after: 2.weeks
  end
end
