# frozen_string_literal: true

require "text-table"
module MailHelper
  def hash_table(h1, h2, hash)
    table = Text::Table.new
    table.head = [h1, h2]
    hash.each do |k, v|
      table.rows << [k, v]
    end
    table
  end

  def array_table(h1, h2, array)
    table = Text::Table.new
    table.head = [h1, h2]
    array.each do |arr|
      table.rows << [arr[0], arr[1]]
    end
    table
  end

  def pluck_table(headers, data)
    table = Text::Table.new
    table.head = headers
    data.each do |datum|
      table.rows << datum
    end
    table
  end
end
