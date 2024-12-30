# frozen_string_literal: true

class AddTwoFactorBackupableToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :otp_backup_codes, :string, array: true
  end
end
