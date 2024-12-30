# frozen_string_literal: true

class AddSendAccountingNotificationsToToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :send_accounting_notifications_to, :integer, array: true
  end
end
