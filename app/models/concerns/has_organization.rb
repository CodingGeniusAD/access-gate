module HasOrganization
  extend ActiveSupport::Concern

  included do
    has_many :memberships
    has_many :organizations, through: :memberships
  end
end
