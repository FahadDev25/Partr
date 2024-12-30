# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def parts_not_received
    OrderMailer.parts_not_received(Order.first, Order.first.parts_not_received, "test@msi-group.net")
  end

  def reimbursement_notify
    OrderMailer.reimbursement_notify(Order.first)
  end
end
