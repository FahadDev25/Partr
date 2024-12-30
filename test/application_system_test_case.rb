# frozen_string_literal: true

require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Devise::Test::IntegrationHelpers
  driven_by :cuprite, using: :chrome
  def setup
    Capybara.javascript_driver = :cuprite
    Capybara.register_driver(:cuprite) do |app|
      Capybara::Cuprite::Driver.new(app, {
        default_wait_time: 5,
        timeout: 60,
        window_size: [1600, 900],
        browser_options: {
          'no-sandbox': nil,
          browser_path: "/usr/bin/google-chrome-stable",
          headless: true,
          "disable-smooth-scrolling": true }
      })
    end
    Rails.application.routes.default_url_options[:host] = Capybara.current_session.server.host
    Rails.application.routes.default_url_options[:port] = Capybara.current_session.server.port
  end

  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end

  # https://github.com/orchidjs/tom-select/discussions/71#discussioncomment-8721624
  def tom_select(value, from:)
    find(:label, text: /\A#{from}\z/).click
    if value.class == Array
      value.each do |v|
        find("input.dropdown-input").set(v)
        first(".ts-dropdown .ts-dropdown-content .option", text: /#{Regexp.quote(v)}/i).click
      end
    else
      find("input.dropdown-input").set(value)
      first(".ts-dropdown .ts-dropdown-content .option", text: /#{Regexp.quote(value)}/i).click
    end
  end
end
