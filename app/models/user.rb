# frozen_string_literal: true

class User < ApplicationRecord
  require "rqrcode"

  # Include default devise modules. Others available are:
  # :confirmable, :trackable, :omniauthable, :database_authenticatable, :timeoutable
  devise :invitable, :rememberable, :validatable, :recoverable, :lockable, :registerable
  devise :two_factor_authenticatable
  devise :two_factor_backupable, otp_number_of_backup_codes: 20

  acts_as_tenant :organization

  validates :email, presence: true
  validates_uniqueness_of :email
  validates_uniqueness_to_tenant :username

  has_one :owned_org, class_name: "Organization"
  has_one :employee, dependent: :destroy
  belongs_to :current_team, class_name: "Team", foreign_key: "team_id"
  has_and_belongs_to_many :teams, join_table: "team_members"
  has_many :orders
  has_many :team_members, dependent: :delete_all
  has_many :jobs, foreign_key: :project_manager_id
  has_many :pinned_jobs, dependent: :destroy

  class Error < StandardError
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def is_admin
    Employee.find_by(user_id: self.id)&.is_admin || (owned_org && owned_org == current_team&.organization)
  end

  def reassign_orders
    first_admin = Employee.where(is_admin: true).where("user_id != #{id}").first
    if !first_admin
      raise Error.new "Can't delete last admin"
    end
    orders.each do |o|
      o.user_id = first_admin&.id
      o.save!
    end
  end

  def set_current_team(team = nil)
    if team == nil
      self.team_id = teams&.first&.id || owned_org&.teams&.first&.id
    else
      return unless (teams.include? team) || is_admin
      self.team_id = team&.id
    end
    save!
  end

  def shareable_to_teams
    Team.where.not(id: team_id).order(:name)
  end

  def twofactor_qr_code
    issuer = "partr"

    totp = ROTP::TOTP.new(otp_secret, issuer:)
    uri = totp.provisioning_uri(username)

    qrcode = RQRCode::QRCode.new(uri)

    qrcode = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 240
    )

    Base64.encode64(qrcode.to_s)
  end
end
