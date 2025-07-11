class AgeConsentsController < ApplicationController
  skip_before_action :check_parental_consent
  def approve
    consent = AgeConsent.find_by(approval_token: params[:token])
    if consent&.pending?
      consent.update(status: :approved)
      flash[:notice] = "Parental consent approved. The user can now participate."
    else
      flash[:alert] = "Invalid or already processed consent request."
    end
    render :approve
  end

  def deny
    consent = AgeConsent.find_by(approval_token: params[:token])
    if consent&.pending?
      consent.update(status: :rejected)
      flash[:notice] = "Parental consent denied. The user cannot participate."
    else
      flash[:alert] = "Invalid or already processed consent request."
    end
    render :deny
  end
end
