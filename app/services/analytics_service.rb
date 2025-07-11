class AnalyticsService
  def initialize(organization)
    @organization = organization
  end

  def members_count
    @organization.memberships.count
  end

  def roles_breakdown
    Membership::ROLES.keys.index_with do |role|
      @organization.memberships.select { |m| m.role == role }.count
    end
  end

  def violations_count
    # Placeholder for custom logic
    0
  end

  def new_members_this_month
    @organization.memberships.where("created_at >= ?", Time.zone.now.beginning_of_month).count
  end

  def active_members_count
    @organization.memberships.where(status: Membership::STATUSES[:active]).count
  end

  def inactive_members_count
    @organization.memberships.where.not(status: Membership::STATUSES[:active]).count
  end

  def recent_member_activity(limit = 5)
    @organization.memberships.includes(:user).order(updated_at: :desc).limit(limit)
  end
end
