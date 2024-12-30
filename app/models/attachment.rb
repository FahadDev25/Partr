# frozen_string_literal: true

class Attachment < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :attachable, polymorphic: true

  has_one_attached :file

  validates :file, presence: true

  def attach_file=(file)
    if file.present? && (["image/png", "image/jpg", "image/jpeg"].include? file.content_type)
      path = file.tempfile.path
      image = ImageProcessing::Vips.source(path)
      result = image.resize_to_limit!(1000, 1000)
      file.tempfile = result
    end
    self.file.attach(file)
  end
end
