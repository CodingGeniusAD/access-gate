class AgeParticipationPolicy < ApplicationPolicy
  def access?
    return false unless user
    # Example: Only adults and teens can access certain content
    user.adult? || user.teen?
  end

  def child_content?
    user.child?
  end

  def teen_content?
    user.teen? || user.adult?
  end

  def adult_content?
    user.adult?
  end
end 