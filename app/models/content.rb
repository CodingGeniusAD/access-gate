class Content < ApplicationRecord
  # Age groups (same as User model)
  AGE_GROUPS = { child: 0, teen: 1, adult: 2 }.freeze

  # Content types
  CONTENT_TYPES = %w[article video game discussion].freeze

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 255 }
  validates :body, presence: true, length: { minimum: 10 }
  validates :content_type, presence: true, inclusion: { in: CONTENT_TYPES }
  validates :age_group, presence: true
  validate :age_group_inclusion

  # Scopes
  scope :for_age_group, ->(age_group) { where(age_group: AGE_GROUPS[age_group.to_sym]) }
  scope :accessible_by, ->(user) { where("age_group <= ?", user.age_group_value) }
  scope :by_type, ->(content_type) { where(content_type: content_type) }
  scope :recent, -> { order(created_at: :desc) }

  # Age group helpers
  def age_group
    AGE_GROUPS.key(self[:age_group])
  end

  def age_group=(value)
    if value.is_a?(Symbol) || value.is_a?(String)
      self[:age_group] = AGE_GROUPS[value.to_sym]
    else
      self[:age_group] = value
    end
  end

  def age_group_value
    self[:age_group]
  end

  def child_content?
    age_group_value == AGE_GROUPS[:child]
  end

  def teen_content?
    age_group_value == AGE_GROUPS[:teen]
  end

  def adult_content?
    age_group_value == AGE_GROUPS[:adult]
  end

  # Content access methods
  def accessible_by?(user)
    return false unless user
    user.age_group_value >= age_group_value
  end

  def age_restriction_text
    case age_group
    when :child
      "Suitable for all ages"
    when :teen
      "Suitable for teens and adults"
    when :adult
      "Adults only"
    end
  end

  private

  def age_group_inclusion
    return unless age_group_value.present?

    unless AGE_GROUPS.values.include?(age_group_value)
      errors.add(:age_group, "is not included in the list")
    end
  end
end
