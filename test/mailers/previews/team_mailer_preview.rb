# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/team_mailer
class TeamMailerPreview < ActionMailer::Preview
  def weekly_additional_parts
    TeamMailer.weekly_additional_parts(Team.first)
  end
end
