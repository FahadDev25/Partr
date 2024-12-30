# frozen_string_literal: true

class Comment < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to :organization
  has_rich_text :content
end
