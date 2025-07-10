class AgeConsent < ApplicationRecord
  belongs_to :user

  validates :parent_email, presence: true

  STATUSES = { pending: 0, approved: 1, rejected: 2 }.freeze

  has_secure_token :approval_token

  def status
    STATUSES.key(self[:status])
  end

  def status=(value)
    self[:status] = STATUSES[value.to_sym]
  end

  def pending?
    self[:status] == STATUSES[:pending]
  end

  def approved?
    self[:status] == STATUSES[:approved]
  end

  def rejected?
    self[:status] == STATUSES[:rejected]
  end
end
