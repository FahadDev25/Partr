# frozen_string_literal: true

require "application_system_test_case"

class AttachmentsTest < ApplicationSystemTestCase
  include ActionCable::TestHelper
  setup do
    @attachment = attachments(:one)
    @attachment.file.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png")
    @attachable = @attachment.attachable
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "should show attachment on attachable page" do
    visit polymorphic_url(@attachable)
    assert_text "slip1.png"
  end

  test "should create attachment" do
    visit polymorphic_url(@attachable)
    click_on "Add Attachment"

    attach_file "attachment_attach_file", (Rails.root + "test/fixtures/files/slip2.jpg")
    click_on "Attach"

    assert_text "Attachment was successfully added"
    click_on "Back"
  end

  test "should destroy Attachment" do
    visit polymorphic_url(@attachable)

    within "div##{dom_id(@attachment)}" do
      click_on "Remove", match: :first
    end

    assert_text "Attachment was successfully destroyed"
  end

  test "should broadcast new order attachments" do
    order = orders(:button_order)
    visit order_url(order)
    click_on "Add Attachment"

    attachments = capture_broadcasts "team_#{order.team_id}_order_attachments" do
      attach_file "attachment_attach_file", (Rails.root + "test/fixtures/files/slip2.jpg")
      click_on "Attach"
      sleep 1
    end

    assert_equal 1, attachments.length
    assert attachments.first.include? "refresh"

    assert_text "Attachment was successfully added"
    click_on "Back"
  end
end
