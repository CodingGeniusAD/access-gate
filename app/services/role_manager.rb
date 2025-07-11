class RoleManager
  def initialize(user, organization)
    @user = user
    @organization = organization
  end

  def set_role(role)
    membership = Membership.find_or_initialize_by(user: @user, organization: @organization)
    membership.role = role
    membership.save!
    membership
  end

  def get_role
    membership = Membership.find_by(user: @user, organization: @organization)
    membership&.role
  end
end
