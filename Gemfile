# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.5"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.4.1"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

gem 'dotenv-rails', groups: [:development, :test]
gem 'sprockets-rails'

# Use sqlite3 as the database for Active Record
# gem "sqlite3", "~> 1.4"

# postgresql [https://github.com/ged/ruby-pg]
gem "pg", "~> 1.5", ">= 1.5.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 6.4.3"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production [https://github.com/redis/redis]
gem "redis", "~> 5.1.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Queue up background jobs [https://github.com/sidekiq/sidekiq]
gem "sidekiq", ">= 7.2.4"

# Use Sass to process CSS [https://github.com/rails/sass-rails]
gem "sass-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Fuzzy string matching [https://github.com/kiyoka/fuzzy-string-match]
gem "fuzzy-string-match"

# Font Awesome [https://github.com/FortAwesome/font-awesome-sass]
gem "font-awesome-sass", "~> 6.4.2"

# Jquery [https://github.com/rails/jquery-rails]
gem "jquery-rails"

# make plaintext tables [https://github.com/aptinio/text-table]
gem "text-table", "~> 1.2", ">= 1.2.4"

# validate active storage [https://github.com/aki77/activestorage-validator]
gem "activestorage-validator"

# pagination [https://github.com/ddnexus/pagy]
gem "pagy", "~> 6.4"

# qr codes [https://github.com/whomwah/rqrcode]
gem "rqrcode", "~> 2.0"

# png creation [https://github.com/wvanbergen/chunky_png]
gem "chunky_png", "~> 1.3", ">= 1.3.5"

# User authentication [https://github.com/heartcombo/devise]
gem "devise", "~> 4.9"

# Email invites for devise [https://github.com/scambra/devise_invitable]
gem "devise_invitable", "~> 2.0.0"

# 2 factor authentication for devise [https://github.com/devise-two-factor/devise-two-factor]
gem "devise-two-factor", ">= 6.0.0"

# Modals for popups etc [https://github.com/cmer/ultimate_turbo_modal-rails]
gem "ultimate_turbo_modal", "~> 1.6"

# Browser manipulation without puppeteer [https://github.com/rubycdp/ferrum]
gem "ferrum"

# Multitenancy [https://github.com/ErwinM/acts_as_tenant]
gem "acts_as_tenant", "~> 1.0"

# Charts and Graphs [https://github.com/ankane/chartkick]
gem "chartkick"

# Display times in user's time zone [https://github.com/basecamp/local_time]
gem "local_time"

# Schedule cron jobs [https://github.com/javan/whenever]
gem "whenever", require: false

# Send emails with SendGrid [https://github.com/sendgrid/sendgrid-ruby]
gem "sendgrid-ruby"

# Run commands on s3 storage servers [https://github.com/aws/aws-sdk-rails]
gem "aws-sdk-s3", require: false

# Parse Markdown to display on pages [https://github.com/vmg/redcarpet]
gem "redcarpet"

# Give malicious attacks the rack attack smack [https://github.com/rack/rack-attack]
gem "rack-attack"

# Force higher version of gems to remove vulnerabilities

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Audit gemfile for vulnerabilities [https://github.com/rubysec/bundler-audit]
  gem "bundler-audit"

  # Check application for vulnerabilities [https://github.com/presidentbeef/brakeman]
  gem "brakeman"

  # Find and fix style issues [https://github.com/rubocop/rubocop]
  gem "rubocop"

  # Configure rubocop for rails style [https://github.com/toshimaru/rubocop-rails_config]
  gem "rubocop-rails_config"

  # Deployment [https://github.com/basecamp/kamal]
  gem "kamal"

  # Foreman for running sever with bin/dev [https://github.com/ddollar/foreman]
  gem "foreman"

  # Random words for seed data [https://github.com/faker-ruby/faker]
  gem "faker"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  # Use the capybara system testing library [https://github.com/teamcapybara/capybara]
  gem "capybara"
  # Use cuprite to drive system tests, since we're already using ferrum [https://github.com/rubycdp/cuprite]
  gem "cuprite"
end
