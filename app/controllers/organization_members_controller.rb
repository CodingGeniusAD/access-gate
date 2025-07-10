class OrganizationMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :authorize_admin!
  before_action :authorize_manage_members!, except: [:index]
  before_action :set_membership, only: [:edit, :update, :destroy]

  def index
    @memberships = @organization.memberships.includes(:user)
  end

  def new
    @membership = @organization.memberships.new
  end

  def create
    user = User.find_by(id: params[:membership][:user_id])
    if user.nil?
      flash[:alert] = 'User not found.'
      @membership = @organization.memberships.new # Ensure @membership is set
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream { redirect_to new_organization_organization_member_path(@organization), alert: flash[:alert] }
      end
      return
    end
    unless @organization.allows_participation?(user)
      flash[:alert] = 'User does not meet the participation rules for this organization.'
      @membership = @organization.memberships.new # Ensure @membership is set
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream { redirect_to new_organization_organization_member_path(@organization), alert: flash[:alert] }
      end
      return
    end
    role = params[:membership][:role]
    status = params[:membership][:status] || 'active'
    @membership = @organization.memberships.new(user: user, role: role, status: status)
    if @membership.save
      respond_to do |format|
        format.html { redirect_to organization_organization_members_path(@organization), notice: 'Member added.', status: :see_other }
        format.turbo_stream { redirect_to organization_organization_members_path(@organization), notice: 'Member added.', status: :see_other }
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
  end

  def update
    role = params[:membership][:role]
    status = params[:membership][:status] || 'active'
    if @membership.user_id == @organization.owner_id && status == 'suspended'
      flash[:alert] = 'You cannot suspend the owner of the organization.'
      respond_to do |format|
        format.html { redirect_to organization_organization_members_path(@organization) }
        format.turbo_stream { redirect_to organization_organization_members_path(@organization), status: :see_other }
      end
      return
    end
    respond_to do |format|
      if @membership.update(role: role, status: status)
        format.html { redirect_to organization_organization_members_path(@organization), notice: 'Member updated.' }
        format.turbo_stream { redirect_to organization_organization_members_path(@organization), notice: 'Member updated.', status: :see_other }
      else
        format.html { render :edit }
        format.turbo_stream { render :edit }
      end
    end
  end

  def destroy
    if @membership.user_id == @organization.owner_id
      redirect_to organization_organization_members_path(@organization), alert: 'You cannot remove the organization owner.'
      return
    end
    if @membership.user_id == current_user.id
      redirect_to organization_organization_members_path(@organization), alert: 'You cannot remove yourself.'
      return
    end
    @membership.destroy
    redirect_to organization_organization_members_path(@organization), notice: 'Member removed.'
  end

  def transfer_ownership
    authorize @organization, :transfer_ownership?
    new_owner = User.find_by(id: params[:user_id])
    membership = @organization.memberships.find_by(user_id: new_owner.id)
    unless membership&.admin?
      redirect_to organization_organization_members_path(@organization), alert: 'Ownership can only be transferred to another admin.'
      return
    end
    @organization.update(owner_id: new_owner.id)
    redirect_to organization_organization_members_path(@organization), notice: 'Ownership transferred successfully.'
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_membership
    @membership = @organization.memberships.find(params[:id])
  end

  def authorize_admin!
    authorize @organization, :update?
  end

  def authorize_manage_members!
    authorize @organization, :manage_members?
  end
end 