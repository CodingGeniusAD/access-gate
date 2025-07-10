# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Sample Users
admin_user_1 = User.create!(email: 'admin.user@example.com', password: 'admin@123', date_of_birth: 25.years.ago, age_group: :adult)
moderator_user_1 = User.create!(email: 'mod.user@example.com', password: 'admin@123', date_of_birth: 30.years.ago, age_group: :adult)
member_user_1 = User.create!(email: 'member.user@example.com', password: 'admin@123', date_of_birth: 28.years.ago, age_group: :adult)

admin_user_2 = User.create!(email: 'admin.user2@example.com', password: 'admin@123', date_of_birth: 25.years.ago, age_group: :adult)
moderator_user_2 = User.create!(email: 'mod.user2@example.com', password: 'admin@123', date_of_birth: 18.years.ago, age_group: :adult)
member_user_2 = User.create!(email: 'member.user2@example.com', password: 'admin@123', date_of_birth: 10.years.ago, age_group: :child)

# Sample Organizations
org1 = Organization.create!(name: 'Alpha Org', participation_rules: [{ type: 'age', min: 18 }], analytics: { members: 0 }, owner_id: admin_user_1.id)
org2 = Organization.create!(name: 'Beta Org', participation_rules: [{ type: 'age', min: 13 }], analytics: { members: 0 }, owner_id: admin_user_2.id)

# Memberships
Membership.create!(user: admin_user_1, organization: org1, role: :admin, status: :active)
Membership.create!(user: moderator_user_1, organization: org1, role: :moderator, status: :active)
Membership.create!(user: member_user_1, organization: org1, role: :member, status: :active)

Membership.create!(user: admin_user_2, organization: org2, role: :admin, status: :active)
Membership.create!(user: moderator_user_2, organization: org2, role: :moderator, status: :active)
Membership.create!(user: member_user_2, organization: org2, role: :member, status: :active)

# Participation rules and analytics
org1.update(analytics: { members: org1.memberships.count })
org2.update(analytics: { members: org2.memberships.count })
