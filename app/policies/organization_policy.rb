class OrganizationPolicy < ApplicationPolicy
  def index?
    # Allow public access to view all organizations
    true
  end

  def show?
    # Allow public access to organization details
    true
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
    owner?
  end

  def manage_members?
    owner? || admin?
  end

  def view_members?
    owner? || admin? || moderator?
  end

  def view_analytics?
    owner? || admin? || moderator?
  end

  def manage_content?
    owner? || admin? || moderator?
  end

  def transfer_ownership?
    owner?
  end

  def manage_admins?
    owner? || admin?
  end

  def request_membership?
    user.present? && !member_or_higher?
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
