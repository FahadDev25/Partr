# frozen_string_literal: true

class TeamMailer < ApplicationMailer
  helper :mail

  def weekly_additional_parts(team)
    @team = team
    @new_additional_parts = AdditionalPart.where(job_id: @team.jobs.pluck(:id)).where("created_at > ?", Date.today - 8)
    @changed_additional_parts = AdditionalPart.where(job_id: @team.jobs.pluck(:id)).where("updated_at > ?", Date.today - 8).where.not("created_at > ?", Date.today - 8)
    @jobs = Job.where(id: @new_additional_parts.pluck(:job_id) + @changed_additional_parts.pluck(:job_id))

    mail to: User.where(id: @team.send_accounting_notifications_to).pluck(:email), subject: "Weekly Additional Parts Update"
  end
end
