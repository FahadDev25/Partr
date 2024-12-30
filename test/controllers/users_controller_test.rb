# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @admin = users(:admin)
    @jsmith = users(:johnsmith)
    @empty_user = users(:empty)
    sign_in @admin
    @admin.current_team = @team = teams(:trapsmiths)
    @admin.save!
    ActsAsTenant.current_tenant = @team.organization
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should register user with organization and team" do
    sign_out @admin
    assert_difference("User.unscoped.count") do
      post user_registration_url, params: { user: { first_name: @admin.first_name,
                                        last_name: @admin.last_name,
                                        username: "admin3",
                                        email: "admin3@test.com",
                                        password: "password",
                                        password_confirmation: "password" },
                                        organization_name: "Org1",
                                        team_name: "Team1" }
    end
    assert_redirected_to home_team_url(User.last.current_team)
  end

  test "should register user through invite" do
    user = User.invite!(email: "new_user@bio-next.net", team_id: @team.id, username: "newuser")

    assert_predicate user, :created_by_invite?
    assert_equal "new_user@bio-next.net", user.email
    assert_equal "newuser", user.username
    assert_equal @team.id, user.team_id
    assert_equal ActsAsTenant.current_tenant.id, user.organization_id

    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries.first
    assert_equal "Invitation instructions", mail.subject
    assert_equal ["new_user@bio-next.net"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/#{user.raw_invitation_token}/), mail.text_part.encoded
    assert_match (/#{accept_user_invitation_path}/), mail.text_part.encoded
    assert_match (/#{user.raw_invitation_token}/), mail.html_part.encoded
    assert_match (/#{accept_user_invitation_path}/), mail.html_part.encoded

    User.accept_invitation!(invitation_token: user.raw_invitation_token, password: "123456", password_confirmation: "123456", first_name: "New", last_name: "User")
    user.reload
    assert_equal "New", user.first_name
    assert_equal "User", user.last_name
  end

  test "should show user" do
    get user_url(@admin)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@admin)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@admin), params: { user: { first_name: @admin.first_name,
                                              last_name: @admin.last_name,
                                              username: @admin.username,
                                              email: @admin.email,
                                              is_admin: true,
                                              password: "password",
                                              password_confirmation: "password" } }
    assert_redirected_to user_url(@admin)
  end

  test "should unlock user account" do
    @empty_user.lock_access!
    patch unlock_account_user_url(@empty_user)

    assert_redirected_to users_url
    @empty_user.reload
    assert_predicate @empty_user.locked_at, :blank?
  end

  test "should destroy user" do
    assert_difference("User.unscoped.count", -1) do
      delete user_url(@empty_user)
    end

    assert_redirected_to users_url
  end
end
