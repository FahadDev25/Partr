# frozen_string_literal: true

class UnitMailer < ApplicationMailer
  helper :mail
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.unit_mailer.part_quantity_mismatch.subject
  #
  def part_quantity_mismatch(unit, mismatched_parts, subassembly_mismatched_parts, mail_to)
    @unit = unit
    @mismatched_parts = mismatched_parts
    @subassembly_mismatched_parts = subassembly_mismatched_parts

    mail to: mail_to
  end
end
