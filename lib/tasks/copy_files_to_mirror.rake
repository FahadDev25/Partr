# frozen_string_literal: true

namespace :active_storage do
  task copy_files_to_mirror: [:environment] do
    ActiveStorage::Blob.all.each do |blob|
      if blob.service_name == "local"
        blob.service_name = "mirror"
        blob.save!
      end
      blob.mirror_later
    end
  end
end
