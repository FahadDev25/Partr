# frozen_string_literal: true

class OrderAttachmentPrintJob < ApplicationJob
  queue_as :default

  def perform(attachment)
    team_ids = [attachment.attachable.team_id].concat attachment.attachable.shared_teams.pluck(:id)
    team_ids.concat Team.joins(:role).where("team_roles.all_order = TRUE").pluck(:id)
    team_ids.each do |team_id|
      attachment.broadcast_refresh_to("team_#{team_id}_order_attachments")
    end
  end
end
