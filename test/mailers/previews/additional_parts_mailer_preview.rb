# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/additional_parts_mailer
class AdditionalPartsMailerPreview < ActionMailer::Preview
  def part_quantity_mismatch
    AdditionalPartsMailer.part_quantity_mismatch(AdditionalPart.first, "10/5", "wkindel@bio-next.net")
  end
end
