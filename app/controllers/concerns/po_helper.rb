# frozen_string_literal: true

module PoHelper
  def next_po_number(prefix)
    year = (Date.today.year % 100).to_s
    last_order = Order.where("po_number like ?", "#{prefix}-#{year}%").order(:po_number).last
    number = last_order ? (last_order.po_number[(prefix.length + 3)..-1].to_i + 1) : 1
    prefix + "-" + year + number.to_s.rjust(3, "0")
  end
end
