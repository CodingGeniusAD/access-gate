class MembershipVerifier
  def initialize(user, organization)
    @user = user
    @organization = organization
  end

  def call
    membership = Membership.find_by(user: @user, organization: @organization)
    return { member: false } unless membership
    {
      member: true,
      role: membership.role,
      status: membership.status
    }
  end
end 