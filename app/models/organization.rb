class Organization < ApplicationRecord
  has_many :memberships
  has_many :users, through: :memberships
  belongs_to :owner, class_name: 'User', optional: true

  PARTICIPATION_RULE_HANDLERS = {
    "age" => ->(user, rule, org) {
      min = rule["min"]
      max = rule["max"]
      age = if user.date_of_birth
        today = Time.zone.now.to_date
        dob = user.date_of_birth
        a = today.year - dob.year
        a -= 1 if today < dob + a.years
        a
      else
        nil
      end
      age && (min.nil? || age >= min) && (max.nil? || age <= max)
    },
    "role" => ->(user, rule, org) {
      Membership.find_by(user: user, organization: org)&.role.to_s == rule["value"]
    },
    "email_domain" => ->(user, rule, org) {
      user.email.ends_with?("@#{rule['domain']}")
    },
    "legacy" => ->(user, rule, org) {
      # Fallback for legacy string rules
      case rule["value"].to_s.downcase
      when /adults only/
        user.respond_to?(:adult?) ? user.adult? : true
      when /teens and above/
        user.respond_to?(:teen?) && user.teen? || user.respond_to?(:adult?) && user.adult?
      when /members only/
        org.memberships.exists?(user: user)
      else
        true
      end
    }
  }

  def allows_participation?(user)
    return false unless user
    rules = participation_rules
    # Normalize rules to array of hashes
    if rules.is_a?(String)
      rules = [{ "type" => "legacy", "value" => rules }]
    elsif rules.is_a?(Hash)
      rules = [rules]
    elsif rules.nil?
      rules = []
    end
    Array(rules).all? do |rule|
      handler = PARTICIPATION_RULE_HANDLERS[rule["type"]]
      if handler
        handler.call(user, rule, self)
      else
        false
      end
    end
  end

  def non_members
    User.where.not(id: memberships.select(:user_id))
  end

  def owner?(user)
    owner_id == user.id
  end
end
