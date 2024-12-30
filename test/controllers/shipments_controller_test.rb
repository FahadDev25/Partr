# frozen_string_literal: true

require "test_helper"

class ShipmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @shipment = shipments(:button_shipment)
    @shipment.packing_slips.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png")
    @jobless_shipment = shipments(:jobless)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get team_shipments_url(@team)
    assert_response :success
  end

  test "should get new" do
    get new_team_shipment_url(@team)
    assert_response :success
  end

  test "should create shipment" do
    emails = capture_emails do
      assert_difference("Shipment.count") do
        post team_shipments_url(@team),
            params: {
              shipment: {
                date_received: @shipment.date_received,
                from: @shipment.from,
                job_id: @shipment.job_id,
                notes: @shipment.notes,
                order_id: @shipment.order_id,
                shipping_number: @shipment.shipping_number,
                organization_id: @team.organization_id,
                team_id: @team.id,
                packing_slips: [fixture_file_upload("slip1.png", "image/png"), fixture_file_upload("slip2.jpg", "image/jpeg")]
              }
            }
      end

      assert_redirected_to shipment_url(Shipment.last)
    end

    assert_equal 1, emails.count

    mail = emails.last
    assert_equal ["admin@bio-next.net"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/#{@shipment.from}/), mail.text_part.encoded
    assert_match (/#{@shipment.shipping_number}/), mail.text_part.encoded
    assert_match (/#{@shipment.from}/), mail.html_part.encoded
    assert_match (/#{@shipment.shipping_number}/), mail.html_part.encoded
  end

  test "should create shipment without job or order" do
    assert_difference("Shipment.count") do
      post team_shipments_url(@team),
          params: {
            shipment: {
              date_received: @shipment.date_received,
              from: @shipment.from,
              job_id: nil,
              notes: @shipment.notes,
              order_id: nil,
              shipping_number: @shipment.shipping_number,
              organization_id: @team.organization_id,
              team_id: @team.id,
              packing_slips: [fixture_file_upload("slip1.png", "image/png"), fixture_file_upload("slip2.jpg", "image/jpeg")]
            }
          }
    end

    assert_redirected_to shipment_url(Shipment.last)
  end

  test "should show shipment" do
    get shipment_url(@shipment)
    assert_response :success
  end

  test "should get edit" do
    get edit_shipment_url(@shipment)
    assert_response :success
  end

  test "should update shipment" do
    patch shipment_url(@shipment),
          params: { shipment: { date_received: @shipment.date_received,
                                from: @shipment.from, job_id: @shipment.job_id,
                                notes: @shipment.notes,
                                order_id: @shipment.order_id,
                                shipping_number: @shipment.shipping_number } }
    assert_redirected_to shipment_url(@shipment)
  end

  test "should destroy shipment" do
    assert_difference("Shipment.count", -1) do
      delete shipment_url(@shipment)
    end

    assert_redirected_to team_shipments_url(@team)
  end

  test "should have packing slip" do
    assert_not @shipment.packing_slips.empty?
  end
end
