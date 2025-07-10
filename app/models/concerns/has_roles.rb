module HasRoles
  extend ActiveSupport::Concern

  def admin?
    role_admin?
  end

  def moderator?
    role_moderator?
  end

  def member?
    role_member?
  end
end 