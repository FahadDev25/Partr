# frozen_string_literal: true

require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @comment = comments(:one)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get new" do
    get new_comment_url
    assert_response :success
  end

  test "should create comment" do
    assert_difference("Comment.count") do
      post comments_url, params: {
        comment: {
          commentable_type: "Order",
          commentable_id: orders(:button_order).id,
          user_id: @user.id,
          organization_id: @user.organization_id,
          content: @comment.content
        }
      }
    end

    assert_redirected_to polymorphic_url(Comment.last.commentable)
  end

  test "should get edit" do
    get edit_comment_url(@comment)
    assert_response :success
  end

  test "should update comment" do
    patch comment_url(@comment), params: {
      comment: {
        commentable_type: @comment.commentable_type,
        commentable_id: @comment.commentable_id,
        user_id: @comment.user_id,
        organization_id: @comment.organization_id,
        content: comments(:two).content
      }
    }
    assert_redirected_to polymorphic_url(@comment.commentable)
  end

  test "should destroy comment" do
    assert_difference("Comment.count", -1) do
      delete comment_url(@comment)
    end

    assert_redirected_to polymorphic_url(@comment.commentable)
  end
end
