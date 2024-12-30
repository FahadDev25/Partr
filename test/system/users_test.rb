# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin)
    @admin2 = users(:admin2)
    @jsmith = users(:johnsmith)
    @jim = users(:jim)
    @empty_user = users(:empty)
    @jsmith.current_team = @team = teams(:trapsmiths)
    @jsmith.save!
    @admin.current_team = @team
    @admin.save!
    @admin2.current_team = @team
    @admin2.save!
    @jim.current_team = @team
    @jim.save!
  end

  test "visiting the index" do
    sign_in @admin
    visit users_url
    assert_selector "h1", text: "Users"
  end

  test "should register user and organization" do
    visit new_user_registration_url

    fill_in "Username", with: "admin4"
    fill_in "Email", with: "admin4@bio-next.net"
    fill_in "Password", with: "123456"
    fill_in "Password confirmation", with: "123456"
    fill_in "First name", with: @admin.first_name
    fill_in "Last name", with: @admin.last_name
    fill_in "organization_name", with: "org1"
    fill_in "team_name", with: "team1"

    click_on "Sign Up", match: :first

    user = User.last
    assert_equal "admin4", user.username
    assert_equal "admin4@bio-next.net", user.email
    assert_equal @admin.first_name, user.first_name
    assert_equal @admin.last_name, user.last_name

    org = Organization.last
    assert_equal "org1", org.name
    assert_equal user.organization_id, org.id

    team = Team.last
    assert_equal "team1", team.name
    assert_equal user.team_id, team.id
    assert_equal org.id, team.organization_id
  end

  test "should create user through invite" do
    sign_in @admin
    visit new_user_invitation_url

    fill_in "Username", with: "admin4"
    fill_in "Email", with: "admin4@bio-next.net"
    select @team.name, from: "Team"
    check "admin_checkbox"

    assert_difference "ActionMailer::Base.deliveries.size" do
      click_on "Send invitation"
      assert_text "An invitation email has been sent to admin4@bio-next.net."
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal "Invitation instructions", mail.subject
    assert_equal ["admin4@bio-next.net"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/#{accept_user_invitation_path}/), mail.text_part.encoded
    assert_match (/#{accept_user_invitation_path}/), mail.html_part.encoded

    user = User.last
    assert_predicate user, :created_by_invite?
    assert_equal "admin4@bio-next.net", user.email
    assert_equal "admin4", user.username
    assert_equal @team.id, user.team_id
    assert_equal @admin.organization_id, user.organization_id

    employee = Employee.last
    assert_equal user.id, employee.user_id
    assert_equal user.organization_id, employee.organization_id
    assert_equal true, employee.is_admin

    click_on "Log Out"

    assert_text "Sign In"

    page = Capybara.string(mail.html_part.encoded)
    url = page.find(:link, "Accept invitation")[:href]

    visit url

    fill_in "First name", with: @admin.first_name
    fill_in "Last name", with: @admin.last_name
    fill_in "Password", with: "123456"
    fill_in "Password confirmation", with: "123456"
    click_on "Submit"

    user.reload
    assert_equal @admin.first_name, user.first_name
    assert_equal @admin.last_name, user.last_name

    team_member = TeamMember.last
    assert_equal user.id, team_member.user_id
    assert_equal user.team_id, team_member.team_id
    assert_equal user.organization_id, team_member.organization_id

    assert_text "Welcome, #{user.first_name}"
  end

  test "should update User" do
    sign_in @jsmith
    visit user_url(@admin)
    click_on "Edit This User", match: :first

    fill_in "Username", with: "john jones"
    fill_in "First name", with: @admin.first_name
    fill_in "Last name", with: @admin.last_name
    fill_in "Email", with: "admin3@bio-next.net"
    uncheck "admin_checkbox"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_on "Update User"

    assert_text "User was successfully updated"
  end

  test "should destroy User" do
    sign_in @admin
    visit user_url(@empty_user)
    click_on "Destroy This User", match: :first

    assert_text "User was successfully destroyed"
  end

  test "should sign in/out without 2fa" do
    visit new_user_session_path
    fill_in "Email", with: @jim.email
    fill_in "Password", with: "password"
    click_on "Log In", match: :first

    assert_text "Welcome, #{@jim.first_name}"

    click_on "Log Out", match: :first

    click_on "Sign In", match: :first
    assert_selector "h1", text: "Log In"
  end

  test "should redirect to sign in when not signed in" do
    visit home_team_url(@team)
    assert_selector "h1", text: "Log In"
    assert_text "You need to sign in before continuing."
  end

  test "should not allow non-admin user to access user index" do
    sign_in @jim
    visit users_url
    assert_no_selector "h1", text: "Users"
    assert_text "Admins only!"
  end

  test "should allow admin user to unlock other accounts" do
    @jim.lock_access!
    sign_in @admin

    visit users_url
    click_on "Unlock", match: :first

    assert_text "User account unlocked."
  end

  test "should not allow non-admin user to access other users" do
    sign_in @jim
    visit user_url(@admin)
    assert_no_selector "strong", text: "Username"
    assert_text "Admins only!"
  end

  test "should not allow admin user to edit other admins or owner" do
    sign_in @admin

    visit user_url(@admin2)
    click_on "Edit This User"
    assert_text "You are not authorized to edit this user"

    visit user_url(@jsmith)
    click_on "Edit This User"
    assert_text "You are not authorized to edit this user"
  end

  test "should allow owners to edit admins and self" do
    sign_in @jsmith

    visit user_url(@admin2)
    click_on "Edit This User"
    assert_no_text "You are not authorized to edit this user"

    visit user_url(@jsmith)
    click_on "Edit This User"
    assert_no_text "You are not authorized to edit this user"
  end

  test "should allow non-admin user to edit own user" do
    sign_in @jim
    visit home_team_url(@team)
    click_on "Account", match: :first

    fill_in "Password", with: "654321"
    fill_in "Password confirmation", with: "654321"
    fill_in "Current password", with: "password"
    fill_in "First name", with: @empty_user.first_name
    fill_in "Last name", with: @empty_user.last_name
    fill_in "Username", with: "johnjones"
    click_on "Update"

    assert_selector "h1", text: "Log In", wait: 5

    @jim.reload

    fill_in "Email", with: @jim.email
    fill_in "Password", with: "654321"
    click_on "Log In", match: :first

    assert_text "Welcome, #{@jim.first_name}"
  end

  test "should enable 2fa" do
    sign_in @jim
    visit home_team_url(@team)
    click_on "Account", match: :first
    click_on "Enable two factor authentication", match: :first

    @jim.reload

    assert_text "Setup Two Factor Authentication"
    totp = ROTP::TOTP.new(@jim.otp_secret)
    fill_in "OTP", with: totp.now
    click_on "Verify", match: :first

    assert_text "Backup Codes"
  end

  test "should disable 2fa" do
    sign_in @admin
    visit home_team_url(@team)
    click_on "Account", match: :first
    click_on "Disable two factor authentication", match: :first

    assert_text "Disable Two Factor Authentication"
    totp = ROTP::TOTP.new(@admin.otp_secret)
    fill_in "OTP", with: totp.now
    click_on "Disable", match: :first

    assert_text "Two factor authentication successfully disabled"
    @admin.reload

    assert_nil @admin.otp_secret
    assert_equal false, @admin.otp_required_for_login
  end

  test "should login with 2fa" do
    visit new_user_session_url
    fill_in "Email", with: @admin.email
    fill_in "Password", with: "12345"

    click_on "Log In", match: :first
    assert_text "Two Factor Authentication"

    totp = ROTP::TOTP.new(@admin.otp_secret)
    fill_in "OTP", with: totp.now

    click_on "Log In", match: :first

    assert_text "Signed in successfully"
  end

  test "should accept backup codes" do
    codes = @admin.generate_otp_backup_codes!
    @admin.save!
    @admin.reload
    visit new_user_session_url
    fill_in "Email", with: @admin.email
    fill_in "Password", with: "12345"

    click_on "Log In", match: :first
    assert_text "Two Factor Authentication"

    fill_in "OTP", with: codes[0]

    click_on "Log In", match: :first

    assert_text "Signed in successfully"

    click_on "Account", match: :first
    click_on "Disable two factor authentication", match: :first

    fill_in "OTP", with: codes[1]

    click_on "Disable", match: :first

    assert_text "Two factor authentication successfully disabled"
    @admin.reload

    assert_nil @admin.otp_secret
    assert_equal false, @admin.otp_required_for_login
  end

  test "should redirect user to enable 2fa when user force_2fa is true" do
    @f2fa = users(:forced_2fa)
    visit new_user_session_url
    fill_in "Email", with: @f2fa.email
    fill_in "Password", with: "password"

    click_on "Log In", match: :first

    assert_selector "h1", text: "Setup Two Factor Authentication"
  end

  test "should redirect user to enable 2fa when organization force_2fa is true" do
    @no_2fa = users(:no_2fa)
    visit new_user_session_url
    fill_in "Email", with: @no_2fa.email
    fill_in "Password", with: "password"

    click_on "Log In", match: :first

    assert_selector "h1", text: "Setup Two Factor Authentication"
  end

  test "should search and filter the index" do
    sign_in @admin
    visit users_url
    assert_text @admin.username
    assert_text @jsmith.username

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @admin.username, :enter

    assert_text @admin.email
    assert_no_text @jsmith.username

    click_on "\u2716", match: :first

    assert_text @jsmith.username
    assert_text @admin.username

    click_on "Filters", match: :first

    fields = [ ["username", @admin.username], ["first_name", @admin.first_name], ["last_name", @admin.last_name], ["email", @admin.email], ["is_admin", @admin.is_admin] ]

    fields.each do |field|
      if field[0] == "is_admin"
        select @admin.is_admin ? "true" : "false", from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @admin.username
      assert_no_text @jsmith.username

      click_on "Reset", match: :first

      assert_text @admin.username
      assert_text @jsmith.username
    end

    assert_text @admin.username
    assert_text @jsmith.username
  end

  test "should sort index by column" do
    sign_in @admin
    visit users_url

    assert_text @admin.username
    assert_text @jsmith.username

    sort_array = [["Username", [@admin.username, @jsmith.username]], ["First Name", [@admin.username, @jsmith.username]], ["Last Name", [@admin.username, @jsmith.username]],
                  ["Email", [@admin.username, @jsmith.username]], ["Admin", [@jsmith.username, @admin.username]]]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.click
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 5)
      header.click
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 5)
    end
  end
end
