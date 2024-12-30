# frozen_string_literal: true

class AdditionalPartsMailer < ApplicationMailer
  helper :mail
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.additional_part_mailer.part_quantity_mismatch.subject
  #
  def part_quantity_mismatch(additional_part, mismatch, mail_to)
    @additional_part = additional_part
    @mismatch = mismatch

    mail to: mail_to
  end
end
