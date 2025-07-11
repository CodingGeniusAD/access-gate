# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Creating sample users for different age groups..."

# Child Users (age_group: 0)
child_user_1 = User.create!(email: 'child1@test.com', password: 'admin@123', date_of_birth: 10.years.ago, age_group: :child)
child_user_2 = User.create!(email: 'child2@test.com', password: 'admin@123', date_of_birth: 8.years.ago, age_group: :child)

# Teen Users (age_group: 1)
teen_user_1 = User.create!(email: 'teen1@test.com', password: 'admin@123', date_of_birth: 15.years.ago, age_group: :teen)
teen_user_2 = User.create!(email: 'teen2@test.com', password: 'admin@123', date_of_birth: 16.years.ago, age_group: :teen)

# Adult Users (age_group: 2)
adult_user_1 = User.create!(email: 'adult1@test.com', password: 'admin@123', date_of_birth: 25.years.ago, age_group: :adult)
adult_user_2 = User.create!(email: 'adult2@test.com', password: 'admin@123', date_of_birth: 30.years.ago, age_group: :adult)

# Admin/Owner Users (all adults)
admin_user_1 = User.create!(email: 'admin1@test.com', password: 'admin@123', date_of_birth: 35.years.ago, age_group: :adult)
admin_user_2 = User.create!(email: 'admin2@test.com', password: 'admin@123', date_of_birth: 28.years.ago, age_group: :adult)

# Moderator Users (all adults)
moderator_user_1 = User.create!(email: 'mod1@test.com', password: 'admin@123', date_of_birth: 32.years.ago, age_group: :adult)
moderator_user_2 = User.create!(email: 'mod2@test.com', password: 'admin@123', date_of_birth: 27.years.ago, age_group: :adult)

puts "Creating age consent records for users under 18..."

# Create and approve age consent for child users
AgeConsent.create!(
  user: child_user_1,
  parent_email: 'parent1@test.com',
  status: :approved
)

AgeConsent.create!(
  user: child_user_2,
  parent_email: 'parent2@test.com',
  status: :approved
)

# Create and approve age consent for teen users
AgeConsent.create!(
  user: teen_user_1,
  parent_email: 'parent3@test.com',
  status: :approved
)

AgeConsent.create!(
  user: teen_user_2,
  parent_email: 'parent4@test.com',
  status: :approved
)

puts "Creating sample organizations..."

# Sample Organizations with different age restrictions
org1 = Organization.create!(name: 'Family Learning Center', participation_rules: [ { type: 'age', min: 5 } ], analytics: { members: 0 }, owner_id: admin_user_1.id)
org2 = Organization.create!(name: 'Teen Innovation Hub', participation_rules: [ { type: 'age', min: 13 } ], analytics: { members: 0 }, owner_id: admin_user_2.id)
org3 = Organization.create!(name: 'Professional Network', participation_rules: [ { type: 'age', min: 18 } ], analytics: { members: 0 }, owner_id: admin_user_1.id)

puts "Creating memberships based on age requirements..."

# Organization 1: Family Learning Center (all ages welcome - min age 5)
# All users meet the age requirement (5+ years old)
Membership.create!(user: admin_user_1, organization: org1, role: :admin, status: :active)
Membership.create!(user: moderator_user_1, organization: org1, role: :moderator, status: :active)
Membership.create!(user: child_user_1, organization: org1, role: :member, status: :active)
Membership.create!(user: child_user_2, organization: org1, role: :member, status: :active)
Membership.create!(user: teen_user_1, organization: org1, role: :member, status: :active)
Membership.create!(user: teen_user_2, organization: org1, role: :member, status: :active)
Membership.create!(user: adult_user_1, organization: org1, role: :member, status: :active)
Membership.create!(user: adult_user_2, organization: org1, role: :member, status: :active)

# Organization 2: Teen Innovation Hub (teens and adults - min age 13)
# Only teens (15, 16) and adults (25, 30, 35, 28, 32, 27) meet the age requirement
Membership.create!(user: admin_user_2, organization: org2, role: :admin, status: :active)
Membership.create!(user: moderator_user_2, organization: org2, role: :moderator, status: :active)
Membership.create!(user: teen_user_1, organization: org2, role: :member, status: :active)
Membership.create!(user: teen_user_2, organization: org2, role: :member, status: :active)
Membership.create!(user: adult_user_1, organization: org2, role: :member, status: :active)
Membership.create!(user: adult_user_2, organization: org2, role: :member, status: :active)

# Organization 3: Professional Network (adults only - min age 18)
# Only adults (25, 30, 35, 28, 32, 27) meet the age requirement
Membership.create!(user: admin_user_1, organization: org3, role: :admin, status: :active)
Membership.create!(user: moderator_user_1, organization: org3, role: :moderator, status: :active)
Membership.create!(user: adult_user_1, organization: org3, role: :member, status: :active)
Membership.create!(user: adult_user_2, organization: org3, role: :member, status: :active)

# Update analytics
org1.update(analytics: { members: org1.memberships.count })
org2.update(analytics: { members: org2.memberships.count })
org3.update(analytics: { members: org3.memberships.count })

puts "Creating sample content for age-appropriate filtering..."

# Sample Content for Age-Appropriate Filtering
# Child Content (Suitable for all ages) - age_group: 0
Content.create!(
  title: "Fun Science Experiments for Kids",
  body: "Learn about science through fun and safe experiments you can do at home! This article covers simple experiments like making a volcano with baking soda and vinegar, creating a rainbow with a glass of water, and learning about density with oil and water. All experiments are safe for children and require adult supervision.",
  content_type: "article",
  age_group: 0
)

Content.create!(
  title: "Educational Games for Learning",
  body: "Discover amazing educational games that make learning fun! From math puzzles to word games, these activities help children develop important skills while having a great time. Perfect for family game nights and classroom activities.",
  content_type: "game",
  age_group: 0
)

Content.create!(
  title: "How to Draw Cartoon Animals",
  body: "Step-by-step guide to drawing cute cartoon animals. Learn to draw cats, dogs, elephants, and more with simple shapes and easy-to-follow instructions. Great for developing artistic skills and creativity in children.",
  content_type: "video",
  age_group: 0
)

# Teen Content (Suitable for teens and adults) - age_group: 1
Content.create!(
  title: "Understanding Social Media Safety",
  body: "Important guide for teens about staying safe on social media platforms. Learn about privacy settings, recognizing online predators, protecting personal information, and maintaining a positive digital footprint. Essential reading for responsible social media use.",
  content_type: "article",
  age_group: 1
)

Content.create!(
  title: "Career Planning for High School Students",
  body: "Comprehensive guide to exploring career options and planning your future. Discover different career paths, required education, job outlook, and how to gain relevant experience. Includes tips for choosing the right college major and building a strong resume.",
  content_type: "article",
  age_group: 1
)

Content.create!(
  title: "Healthy Relationships Discussion",
  body: "Open discussion about building and maintaining healthy relationships. Topics include communication skills, setting boundaries, recognizing red flags, and understanding consent. Important information for teens navigating friendships and romantic relationships.",
  content_type: "discussion",
  age_group: 1
)

# Adult Content (Adults only) - age_group: 2
Content.create!(
  title: "Advanced Financial Planning Strategies",
  body: "In-depth guide to advanced financial planning including investment strategies, retirement planning, tax optimization, and estate planning. Covers complex financial instruments, risk management, and long-term wealth building techniques for experienced investors.",
  content_type: "article",
  age_group: 2
)

Content.create!(
  title: "Professional Development and Leadership",
  body: "Comprehensive guide to advancing your career through leadership development, strategic thinking, and professional networking. Includes advanced management techniques, conflict resolution strategies, and organizational psychology principles.",
  content_type: "article",
  age_group: 2
)

Content.create!(
  title: "Complex Social Issues Discussion",
  body: "Mature discussion about complex social, political, and ethical issues facing society today. Topics include systemic inequality, environmental challenges, technological disruption, and global economic trends. Requires critical thinking and mature perspective.",
  content_type: "discussion",
  age_group: 2
)

puts "Sample content created successfully!"
puts "Created #{Content.count} pieces of content"
puts "Child content: #{Content.where(age_group: 0).count}"
puts "Teen content: #{Content.where(age_group: 1).count}"
puts "Adult content: #{Content.where(age_group: 2).count}"

puts "\n=== Test Account Credentials ==="
puts "Child Users (with approved parental consent):"
puts "  child1@test.com / admin@123"
puts "  child2@test.com / admin@123"
puts "\nTeen Users (with approved parental consent):"
puts "  teen1@test.com / admin@123"
puts "  teen2@test.com / admin@123"
puts "\nAdult Users:"
puts "  adult1@test.com / admin@123"
puts "  adult2@test.com / admin@123"
puts "\nAdmin Users:"
puts "  admin1@test.com / admin@123"
puts "  admin2@test.com / admin@123"
puts "\nModerator Users:"
puts "  mod1@test.com / admin@123"
puts "  mod2@test.com / admin@123"

puts "\n=== Organization Memberships ==="
puts "Family Learning Center (min age 5): All users can join"
puts "Teen Innovation Hub (min age 13): Teens and adults only"
puts "Professional Network (min age 18): Adults only"

puts "\nDatabase setup complete!"
