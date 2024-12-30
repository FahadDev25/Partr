# frozen_string_literal: true

require "test_helper"

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @attachment = attachments(:one)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get new" do
    get new_attachment_url
    assert_response :success
  end

  test "should create attachment" do
    assert_difference("Attachment.count") do
      post attachments_url, params: {
        attachment: {
          attachable_id: @attachment.attachable_id,
          attachable_type: @attachment.attachable_type,
          organization_id: @attachment.organization_id,
          attach_file: fixture_file_upload("slip1.png", "image/png")
        }
      }
    end

    assert_redirected_to polymorphic_url(Attachment.last.attachable)
  end

  test "should destroy attachment" do
    assert_difference("Attachment.count", -1) do
      delete attachment_url(@attachment)
    end

    assert_redirected_to polymorphic_url(@attachment.attachable)
  end
end
