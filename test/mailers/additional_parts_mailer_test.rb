# frozen_string_literal: true

require "test_helper"

class AdditionalPartsMailerTest < ActionMailer::TestCase
  test "part_quantity_mismatch" do
    mail = AdditionalPartsMailer.part_quantity_mismatch(additional_parts(:more_pane), "2/1", "me@bio-next.net")
    assert_equal "Part quantity mismatch", mail.subject
    assert_equal ["me@bio-next.net"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/gbc101/), mail.text_part.encoded
    assert_match (/2\/1/), mail.text_part.encoded
    assert_match (/gbc101/), mail.html_part.encoded
    assert_match (/2\/1/), mail.html_part.encoded
  end
end
