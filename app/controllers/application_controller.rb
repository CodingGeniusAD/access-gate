class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pundit

  before_action :check_parental_consent

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || root_path)
  end

  def check_parental_consent
    return unless user_signed_in?
    return if current_user.parental_consent_approved?
    sign_out current_user
    flash[:alert] = 'Parental consent is required and not yet approved. Please check your email for instructions.'
    redirect_to new_user_session_path
  end
end
