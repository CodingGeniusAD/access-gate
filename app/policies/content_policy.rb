class ContentPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    return false unless user.present?
    record.accessible_by?(user)
  end

  def create?
    user.present? && (user.adult? || user.teen?)
  end

  def new?
    create?
  end

  def update?
    return false unless user.present?
    # Only allow updating content if user meets the age requirement
    record.accessible_by?(user) && (user.adult? || user.teen?)
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user.present?
    # Only allow destroying content if user meets the age requirement
    record.accessible_by?(user) && (user.adult? || user.teen?)
  end

  # Custom method to check if user can create content for a specific age group
  def can_create_for_age_group?(age_group)
    return false unless user.present?
    return false unless user.adult? || user.teen?

    case age_group.to_sym
    when :child
      # Teens and adults can create child content
      true
    when :teen
      # Only adults can create teen content (teens can only create child content)
      user.adult?
    when :adult
      # Only adults can create adult content
      user.adult?
    else
      false
    end
  end

  class Scope < Scope
    def resolve
      return scope.none unless user.present?
      scope.accessible_by(user)
    end
  end
end
