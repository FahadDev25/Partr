# frozen_string_literal: true

class AddOrderReceivedEmailTimerToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :order_received_email_timer, :string
  end
end
