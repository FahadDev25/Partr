# frozen_string_literal: true

class AddPrintedToAttachments < ActiveRecord::Migration[7.1]
  def change
    add_column :attachments, :printed, :boolean, default: false
  end
end
