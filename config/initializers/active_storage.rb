# frozen_string_literal: true

# config/initializers/active_storage.rb
Rails.application.config.after_initialize do
  ActiveStorage::BaseController.class_eval do
    before_action :authenticate_user!
  end
end
