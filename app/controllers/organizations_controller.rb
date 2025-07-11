class OrganizationsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_organization, only: [ :show, :edit, :update, :destroy ]

  def index
    # Show all organizations to all users
    @organizations = Organization.all
    authorize Organization
  end

  def show
    @organization = Organization.find(params[:id])
    authorize @organization

    # Check if user is authenticated and has membership
    if user_signed_in?
      membership = @organization.memberships.find_by(user_id: current_user.id)
      if membership && membership.suspended?
        flash.now[:alert] = "Your membership has been suspended by an admin. You need an active membership to access this organization."
        render "organizations/suspended" and return
      end

      # Only load analytics and recent activity for members
      if membership
        @analytics = AnalyticsService.new(@organization)
        @recent_activity = @analytics.recent_member_activity
      end
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
      redirect_to @organization, notice: "Organization was successfully created."
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
      redirect_to @organization, notice: "Organization was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    authorize @organization
    if @organization.destroy
      redirect_to organizations_path, notice: "Organization was successfully deleted."
    else
      redirect_to organizations_path, alert: "Failed to delete organization."
    end
  end

  def request_membership
    @organization = Organization.find(params[:id])
    authorize @organization, :request_membership?

    # Check if user meets participation rules
    unless @organization.allows_participation?(current_user)
      redirect_to @organization, alert: "You do not meet the participation rules for this organization."
      return
    end

    # Check if membership request already exists
    existing_request = @organization.memberships.find_by(user: current_user)
    if existing_request
      redirect_to @organization, alert: "You already have a membership request for this organization."
      return
    end

    # Create membership request with pending status
    membership = @organization.memberships.new(
      user: current_user,
      role: :member,
      status: :pending
    )

    if membership.save
      redirect_to @organization, notice: "Membership request submitted successfully. An administrator will review your request."
    else
      redirect_to @organization, alert: "Failed to submit membership request: #{membership.errors.full_messages.join(', ')}"
    end
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
