class AgeParticipationPolicy < ApplicationPolicy
  def access?
    return false unless user
    # All authenticated users can access the age participation page
    # Content filtering happens within the page based on user's age group
    true
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
