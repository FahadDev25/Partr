# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  helper :mail

  def parts_not_received(order, not_received_parts, mail_to)
    @order = order
    @not_received_parts = not_received_parts

    mail to: mail_to
  end

  def reimbursement_notify(order)
    @order = order

    mail to: User.where(id: order.team.send_accounting_notifications_to).pluck(:email), subject: "Reimbursement Needed for Order"
  end
end
