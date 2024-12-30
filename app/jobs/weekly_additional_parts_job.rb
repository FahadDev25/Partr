# frozen_string_literal: true

class WeeklyAdditionalPartsJob < ApplicationJob
  queue_as :default

  def perform
    return if Rails.env.staging?
    Team.where.not(send_accounting_notifications_to: nil).each do |team|
      TeamMailer.weekly_additional_parts(team).deliver_later!
    end
  end
end
