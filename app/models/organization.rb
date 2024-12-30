# frozen_string_literal: true

class Organization < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: "user_id", optional: true
  belongs_to :hq_address, class_name: "Address", foreign_key: "address_id", optional: true
  belongs_to :billing_address, class_name: "Address", foreign_key: "billing_address_id", optional: true
  has_many :teams
  has_one_attached :logo, dependent: :destroy do |blob|
    blob.variant :thumb, resize_to_limit: [125, 75]
  end

  accepts_nested_attributes_for :hq_address, :billing_address, reject_if: :all_blank

  before_destroy :remove_owner, :remove_addresses, prepend: true

  has_many :attachments, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :parts_received, dependent: :destroy
  has_many :shipments, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :components, dependent: :destroy
  has_many :subassemblies, dependent: :destroy
  has_many :assemblies, dependent: :destroy
  has_many :additional_parts, dependent: :destroy
  has_many :units, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :parts, dependent: :destroy
  has_many :other_part_numbers, dependent: :destroy
  has_many :manufacturers, dependent: :destroy
  has_many :vendors, dependent: :destroy
  has_many :price_changes, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :team_roles, dependent: :destroy
  has_many :addresses, dependent: :destroy

  encrypts :mcmaster_certificate
  encrypts :mcmaster_username
  encrypts :mcmaster_password

  validates :name, presence: { message: "Organization name can't be blank" }
  validates_uniqueness_of :owner

  def logo_base64
    Base64.encode64(logo.download)
  end

  def remove_addresses
    self.address_id = nil
    self.billing_address_id = nil
    save!
  end

  def remove_owner
    self.user_id = nil
    save!
  end
end
