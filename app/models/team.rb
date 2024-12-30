# frozen_string_literal: true

class Team < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :organization
  belongs_to :team_address, class_name: "Address", foreign_key: "address_id", optional: true
  belongs_to :billing_address, class_name: "Address", foreign_key: "billing_address_id", optional: true
  belongs_to :role, class_name: "TeamRole", foreign_key: "team_role_id"

  has_many :team_members, dependent: :delete_all
  has_many :shared_records, dependent: :destroy
  has_many :users, through: :team_members

  has_many :shared_parts, source: :shareable, source_type: "Part", through: :shared_records
  has_many :shared_assemblies, source: :shareable, source_type: "Assembly", through: :shared_records
  has_many :shared_jobs, source: :shareable, source_type: "Job", through: :shared_records
  has_many :shared_orders, source: :shareable, source_type: "Order", through: :shared_records
  has_many :shared_shipments, source: :shareable, source_type: "Shipment", through: :shared_records

  validates :name, presence: { message: "Team name can't be blank" }
  validates :optional_part_field_1_name, presence: true, if: :show_optional_part_field_1
  validates :optional_part_field_2_name, presence: true, if: :show_optional_part_field_2

  accepts_nested_attributes_for :team_address, :billing_address, reject_if: :all_blank

  def assemblies
    Assembly.where(team_id: id).or(Assembly.where(id: shared_assemblies.pluck(:id)))
  end

  def copy_org_phone
    self.phone_number = organization.phone_number
    save!
  end

  def jobs
    role.all_job ? Job.all : Job.where(team_id: id).or(Job.where(id: shared_jobs.pluck(:id)))
  end

  def order_email_timer_seconds
    timer_array = order_received_email_timer.split(" ")
    timer_array[0].to_i.send(timer_array[1])
  end

  def order_email_timer_number
    order_received_email_timer ? order_received_email_timer.split(" ")[0] : nil
  end

  def order_email_timer_text
    order_received_email_timer ? order_received_email_timer.split(" ")[1] : nil
  end

  def orders
    role.all_order ? Order.all : Order.where(team_id: id).or(Order.where(id: shared_orders.pluck(:id)))
  end

  def parts
    Part.where(team_id: id).or(Part.where(id: shared_parts.pluck(:id)))
  end

  def shipments
    role.all_shipment ? Shipment.all : Shipment.where(team_id: id).or(Shipment.where(id: shared_shipments.pluck(:id)))
  end
end
