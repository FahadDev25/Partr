# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/unit_mailer
class UnitMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/unit_mailer/part_quantity_mismatch
  def part_quantity_mismatch
    UnitMailer.part_quantity_mismatch(Unit.first, { Unit.first.assembly.parts.first.label => "2/1" }, { "Test > Test2" => [["Hoffman Test0", "5/4"]] }, "wkindel@bio-next.net")
  end
end
