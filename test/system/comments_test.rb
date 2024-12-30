# frozen_string_literal: true

require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  include ActionCable::TestHelper
  setup do
    attachments(:one).file.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png")
    @comment = comments(:one)
    @commentable = @comment.commentable
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "should create comment" do
    visit polymorphic_url(@commentable)

    fill_in_rich_text_area "comment_content", with: "new comment"

    comments = capture_broadcasts "#{dom_id @commentable}_comments" do
      click_on "Create Comment"
      sleep 1
    end

    assert_equal 1, comments.length
    assert comments.first.include? "new comment"

    within("div##{dom_id @commentable}_comments") do
      assert_text "new comment", wait: 10
    end
  end

  test "should update Comment" do
    visit polymorphic_url(@commentable)
    within("turbo-frame##{dom_id @comment}") do
      click_on "Edit", match: :first
      assert_text "Cancel"
      click_on "Cancel", match: :first
      assert_no_text "Update Comment"
      click_on "Edit", match: :first
      assert_text "Cancel"

      fill_in_rich_text_area "comment_content", with: "changed comment"

      click_on "Update Comment"

      assert_text "edited"
      assert_text "changed comment"
    end
  end

  test "should destroy Comment" do
    content = @comment.content
    visit polymorphic_url(@commentable)

    within("turbo-frame##{dom_id @comment}") do
      accept_confirm do
        click_on "Delete", match: :first
      end
    end

    assert_no_text content
  end
end
