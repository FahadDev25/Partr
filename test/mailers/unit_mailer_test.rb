# frozen_string_literal: true

require "test_helper"

class UnitMailerTest < ActionMailer::TestCase
  test "part_quantity_mismatch" do
    mail = UnitMailer.part_quantity_mismatch(units(:failsafe), { parts(:big_red_button).label => "2/1" }, { "Test > Test2" => [["Hoffman Test0", "5/4"]] }, "me@bio-next.net")
    assert_equal "Part quantity mismatch", mail.subject
    assert_equal ["me@bio-next.net"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/brb101/), mail.text_part.encoded
    assert_match (/2\/1/), mail.text_part.encoded
    assert_match (/brb101/), mail.html_part.encoded
    assert_match (/2\/1/), mail.html_part.encoded
  end
end
