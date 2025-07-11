class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships
  has_many :organizations, through: :memberships
  has_one :age_consent

  # Manual age group helpers
  AGE_GROUPS = { child: 0, teen: 1, adult: 2 }.freeze

  # Validations
  validates :date_of_birth, presence: true
  validate :date_of_birth_reasonable

  def age_group
    AGE_GROUPS.key(self[:age_group])
  end

  def age_group=(value)
    self[:age_group] = AGE_GROUPS[value.to_sym]
  end

  def age_group_value
    self[:age_group]
  end

  def child?
    self[:age_group] == AGE_GROUPS[:child]
  end

  def teen?
    self[:age_group] == AGE_GROUPS[:teen]
  end

  def adult?
    self[:age_group] == AGE_GROUPS[:adult]
  end

  def parental_consent_required?
    age_group != :adult
  end

  def parental_consent_approved?
    return true unless parental_consent_required?
    age_consent&.approved?
  end

  private

  def date_of_birth_reasonable
    return unless date_of_birth

    if date_of_birth > Date.current
      errors.add(:date_of_birth, "cannot be in the future")
    elsif date_of_birth < 120.years.ago.to_date
      errors.add(:date_of_birth, "appears to be invalid (too far in the past)")
    end
  end
end
