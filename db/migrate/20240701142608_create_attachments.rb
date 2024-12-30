# frozen_string_literal: true

class CreateAttachments < ActiveRecord::Migration[7.1]
  def change
    create_table :attachments do |t|
      t.references :attachable, null: false, polymorphic: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
