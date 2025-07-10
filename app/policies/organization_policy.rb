class OrganizationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && member_or_higher?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    owner? || admin?
  end

  def edit?
    update?
  end

  def destroy?
    owner? || admin?
  end

  def manage_members?
    owner? || admin?
  end

  def transfer_ownership?
    owner?
  end

  private

  def owner?
    record.owner_id == user.id
  end

  def admin?
    m = Membership.find_by(user: user, organization: record)
    m&.admin? && m&.active?
  end

  def moderator?
    m = Membership.find_by(user: user, organization: record)
    m&.moderator? && m&.active?
  end

  def member?
    m = Membership.find_by(user: user, organization: record)
    m&.member? && m&.active?
  end

  def member_or_higher?
    owner? || admin? || moderator? || member?
  end
end 