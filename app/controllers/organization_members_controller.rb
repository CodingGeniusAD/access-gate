class OrganizationMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_membership, only: [ :edit, :update, :destroy ]

  def index
    authorize @organization, :view_members?
    @memberships = @organization.memberships.includes(:user)
    @pending_requests = @organization.memberships.includes(:user).where(status: Membership::STATUSES[:pending])
  end

  def new
    authorize @organization, :manage_members?
    @membership = @organization.memberships.new
  end

  def create
    authorize @organization, :manage_members?
    user = User.find_by(id: params[:membership][:user_id])
    if user.nil?
      flash[:alert] = "User not found."
      @membership = @organization.memberships.new # Ensure @membership is set
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream { redirect_to new_organization_organization_member_path(@organization), alert: flash[:alert] }
      end
      return
    end
    unless @organization.allows_participation?(user)
      flash[:alert] = "User does not meet the participation rules for this organization."
      @membership = @organization.memberships.new # Ensure @membership is set
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream { redirect_to new_organization_organization_member_path(@organization), alert: flash[:alert] }
      end
      return
    end
    role = params[:membership][:role]
    status = params[:membership][:status] || "active"

    # Check if current user can assign this role
    unless can_assign_role?(role)
      flash[:alert] = "You don't have permission to assign this role."
      @membership = @organization.memberships.new
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream { redirect_to new_organization_organization_member_path(@organization), alert: flash[:alert] }
      end
      return
    end

    @membership = @organization.memberships.new(user: user, role: role, status: status)
    if @membership.save
      respond_to do |format|
        format.html { redirect_to organization_organization_members_path(@organization), notice: "Member added.", status: :see_other }
        format.turbo_stream { redirect_to organization_organization_members_path(@organization), notice: "Member added.", status: :see_other }
      end
    else
      flash[:alert] = @membership.errors.full_messages.to_sentence
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream { redirect_to new_organization_organization_member_path(@organization), alert: flash[:alert] }
      end
    end
  end

  def edit
    authorize @organization, :manage_members?
  end

  def update
    authorize @organization, :manage_members?
    role = params[:membership][:role]
    status = params[:membership][:status] || "active"

    # Check if current user can assign this role
    unless can_assign_role?(role)
      flash[:alert] = "You don't have permission to assign this role."
      respond_to do |format|
        format.html { redirect_to organization_organization_members_path(@organization) }
        format.turbo_stream { redirect_to organization_organization_members_path(@organization), status: :see_other }
      end
      return
    end

    if @membership.user_id == @organization.owner_id && status == "suspended"
      flash[:alert] = "You cannot suspend the owner of the organization."
      respond_to do |format|
        format.html { redirect_to organization_organization_members_path(@organization) }
        format.turbo_stream { redirect_to organization_organization_members_path(@organization), status: :see_other }
      end
      return
    end
    respond_to do |format|
      if @membership.update(role: role, status: status)
        format.html { redirect_to organization_organization_members_path(@organization), notice: "Member updated." }
        format.turbo_stream { redirect_to organization_organization_members_path(@organization), notice: "Member updated.", status: :see_other }
      else
        format.html { render :edit }
        format.turbo_stream { render :edit }
      end
    end
  end

  def destroy
    authorize @organization, :manage_members?
    if @membership.user_id == @organization.owner_id
      redirect_to organization_organization_members_path(@organization), alert: "You cannot remove the organization owner."
      return
    end
    if @membership.user_id == current_user.id
      redirect_to organization_organization_members_path(@organization), alert: "You cannot remove yourself."
      return
    end
    @membership.destroy
    redirect_to organization_organization_members_path(@organization), notice: "Member removed."
  end

  def approve_request
    authorize @organization, :manage_members?
    @membership = @organization.memberships.find(params[:id])

    if @membership.update(status: :active)
      redirect_to organization_organization_members_path(@organization), notice: "Membership request approved."
    else
      redirect_to organization_organization_members_path(@organization), alert: "Failed to approve request."
    end
  end

  def reject_request
    authorize @organization, :manage_members?
    @membership = @organization.memberships.find(params[:id])

    if @membership.update(status: :rejected)
      redirect_to organization_organization_members_path(@organization), notice: "Membership request rejected."
    else
      redirect_to organization_organization_members_path(@organization), alert: "Failed to reject request."
    end
  end

  def transfer_ownership
    authorize @organization, :transfer_ownership?
    new_owner = User.find_by(id: params[:user_id])
    membership = @organization.memberships.find_by(user_id: new_owner.id)
    unless membership&.admin?
      redirect_to organization_organization_members_path(@organization), alert: "Ownership can only be transferred to another admin."
      return
    end
    @organization.update(owner_id: new_owner.id)
    redirect_to organization_organization_members_path(@organization), notice: "Ownership transferred successfully."
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_membership
    @membership = @organization.memberships.find(params[:id])
  end

  def can_assign_role?(role)
    return true if @organization.owner_id == current_user.id
    return true if admin?

    false
  end

  def admin?
    m = Membership.find_by(user: current_user, organization: @organization)
    m&.admin? && m&.active?
  end

  def moderator?
    m = Membership.find_by(user: current_user, organization: @organization)
    m&.moderator? && m&.active?
  end

  helper_method :admin?, :moderator?
end
