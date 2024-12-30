# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end
end
