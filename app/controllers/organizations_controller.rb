class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  def index
    @organizations = Organization.joins(:memberships).where(memberships: { user_id: current_user.id })
    authorize Organization
  end

  def show
    @organization = Organization.find(params[:id])
    authorize @organization
    membership = @organization.memberships.find_by(user_id: current_user.id)
    if membership && membership.suspended?
      flash.now[:alert] = 'Your membership has been suspended by an admin. You need an active membership to access this organization.'
      render 'organizations/suspended' and return
    end
    @analytics = AnalyticsService.new(@organization)
    @recent_activity = @analytics.recent_member_activity
    unless @organization.allows_participation?(current_user) || @organization.memberships.exists?(user_id: current_user.id)
      redirect_to organizations_path, alert: 'You do not meet the participation rules for this organization.' and return
    end
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.owner_id = current_user.id
    authorize @organization
    if @organization.save
      Membership.create!(user: current_user, organization: @organization, role: Membership::ROLES[:admin], status: Membership::STATUSES[:active])
      redirect_to @organization, notice: 'Organization was successfully created.'
    else
      render :new
    end
  end

  def edit
    authorize @organization
  end

  def update
    authorize @organization
    if @organization.update(organization_params)
      redirect_to @organization, notice: 'Organization was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @organization
    @organization.destroy
    redirect_to organizations_path, notice: 'Organization was successfully deleted.'
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    permitted = params.require(:organization).permit(:name, :analytics, :participation_rules)
    if permitted[:participation_rules].is_a?(String)
      begin
        permitted[:participation_rules] = JSON.parse(permitted[:participation_rules])
      rescue JSON::ParserError
        permitted[:participation_rules] = []
      end
    end
    permitted
  end
end
