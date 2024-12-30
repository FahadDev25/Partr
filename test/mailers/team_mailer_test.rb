# frozen_string_literal: true

require "test_helper"

class TeamMailerTest < ActionMailer::TestCase
  test "weekly_additional_parts" do
    teams(:trapsmiths).update(send_accounting_notifications_to: [users(:johnsmith).id])
    additional_part_1 = additional_parts(:extra_claws)
    additional_part_2 = additional_parts(:more_pane)
    additional_part_3 = additional_parts(:one_button)
    mail = TeamMailer.weekly_additional_parts(teams(:trapsmiths))
    assert_equal "Weekly Additional Parts Update", mail.subject
    assert_equal [users(:johnsmith).email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_no_match (/#{additional_part_1.job.name}/), mail.text_part.encoded
    assert_match (/#{additional_part_2.job.name}/), mail.text_part.encoded
    assert_match (/#{additional_part_2.part.label}/), mail.text_part.encoded
    assert_match (/#{additional_part_2.quantity}/), mail.text_part.encoded
    assert_match (/#{additional_part_2.quantity * additional_part_2.part.cost_per_unit}/), mail.text_part.encoded
    assert_match (/#{additional_part_3.job.name}/), mail.text_part.encoded
    assert_match (/#{additional_part_3.part.label}/), mail.text_part.encoded
    assert_match (/#{additional_part_3.quantity}/), mail.text_part.encoded
    assert_match (/#{additional_part_3.quantity * additional_part_2.part.cost_per_unit}/), mail.text_part.encoded
  end
end
