class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  include HasRoles

  ROLES = { admin: 0, moderator: 1, member: 2 }.freeze
  STATUSES = { pending: 0, active: 1, suspended: 2 }.freeze

  def role
    ROLES.key(self[:role])
  end

  def role=(value)
    if value.is_a?(Integer)
      self[:role] = value
    else
      self[:role] = ROLES[value.to_sym]
    end
  end

  def admin?
    self[:role] == ROLES[:admin]
  end

  def moderator?
    self[:role] == ROLES[:moderator]
  end

  def member?
    self[:role] == ROLES[:member]
  end

  def status
    STATUSES.key(self[:status])
  end

  def status=(value)
    if value.is_a?(Integer)
      self[:status] = value
    else
      self[:status] = STATUSES[value.to_sym]
    end
  end

  def pending?
    self[:status] == STATUSES[:pending]
  end

  def active?
    self[:status] == STATUSES[:active]
  end

  def suspended?
    self[:status] == STATUSES[:suspended]
  end
end
