# AccessGate

A Rails 8 application for organization-based access control, age-based participation, and parental consent workflows.

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [How AccessGate Works](#how-accessgate-works)
  - [User Roles & Permissions](#user-roles--permissions)
  - [Managing Roles & Permissions](#managing-roles--permissions)
  - [Organization Participation Rules](#organization-participation-rules)
  - [Recent Member Activity & Reporting](#recent-member-activity)
  - [Parental Consent Workflow](#parental-consent-workflow)
  - [Content Filtering by Age](#content-filtering-by-age)
- [Example Data & Test Accounts](#example-data--test-accounts)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites
- Ruby 3.2.3 (use rbenv or rvm)
- PostgreSQL (ensure the service is running)
- Node.js & Yarn (for JS dependencies)
- Bundler (`gem install bundler`)

## Setup Instructions

1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd AccessGate
   ```
2. **Install Ruby dependencies:**
   ```sh
   bundle install
   ```
3. **Install JavaScript dependencies:**
   ```sh
   yarn install
   ```
4. **Set up the database:**
   - Ensure PostgreSQL is running and you have a user with createdb privileges.
   - Create, migrate, and seed the database:
     ```sh
     rails db:drop db:create db:migrate db:seed
     ```
5. **Start the Rails server:**
   ```sh
   rails server
   ```
   The app will be available at [http://localhost:3000](http://localhost:3000)

---

## How AccessGate Works

### User Roles & Permissions

- **Roles:**
  - `admin/Owner`: Full control over the organization (can manage members, content, and settings).
  - `moderator`: Can only view the members and access organization content and features.
  - `member`: Regular participant with access to organization content and features.
- **Membership Statuses:**
  - `active`: Member is active and can participate.
  - `pending`: Membership request is awaiting approval.
  - `suspended`: Member is temporarily blocked from participation.

#### How Roles Work
- Each user can have a different role in each organization they join.
- The organization owner is always an admin and cannot be suspended.

### Managing Roles & Permissions

- **Admins/Owners** can assign any role to members via the organization member management UI:
  - Go to the organization page → "Manage Members" → Edit a member to change their role or status.
  - If the admin is Owner can transfer ownership of an organization to another admin from the members list.
  - Admins can suspend or remove members (except the owner).
- **Adding Members:**
  - Use the "Add Member" button in the members list. Select a user and assign a role (if permitted by your own role).
- **Moderators** can view some of the organization details and also can view the members list in the organization.

### Organization Participation Rules

- Organizations can restrict who can join based on age.
- **Participation rules** are set as JSON in the organization settings (e.g., `{ "type": "age", "min": 13 }`).
- **Examples:**
  - `{ "type": "age", "min": 18 }` → Only adults (18+) can join.
  - `{ "type": "age", "min": 13 }` → Teens and adults (13+) can join.

- **Editing Rules:**
  - Go to the organization page → "Edit" → Update the "Participation Rules" field (as JSON).
  - Example for adults only: `[ { "type": "age", "min": 18 } ]`

---

### Recent Member Activity

- The **Recent Member Activity** section provides a real-time overview of the latest changes and actions by members within an organization.
- This section is displayed on the organization details page for users with appropriate permissions (typically admins and owners).
- It lists:
  - Member email
  - Role
  - Status (active, suspended, etc.)
  - Last updated timestamp
- This replaces traditional analytics and reporting, giving a quick snapshot of who has joined, changed roles, or had their status updated recently.
- You can also download the members list as a CSV for further analysis.

---

### Parental Consent Workflow

- **Age Verification** (children and teens):
  1. During registration, users must enter their date of birth.
  2. If under 18, a parent/guardian email is required.
  3. The parent receives an email with links to approve or deny consent.
  4. The user cannot participate until consent is approved.
  5. If approved, the user gains access; if denied, access is blocked.
- **Consent Email:**
  - Contains "Approve Participation" and "Deny Participation" links for the parent.
- **Consent Status:**
  - Users are automatically moved to dashboard if their consent is not yet approved.
  - Parents see a confirmation message after approving or denying consent.

### Content Filtering by Age

- Content is tagged for different age groups: child, teen, adult.
- Users only see content appropriate for their age group.
- Example:
  - Children see only child content.
  - Teens see child and teen content.
  - Adults see all content.
- Content is filtered automatically in the content library and recommendations.

---

## Example Data & Test Accounts

After running `rails db:seed`, you can use these test accounts:

- **Child Users (with approved parental consent):**
  - `child1@test.com` / `admin@123`
  - `child2@test.com` / `admin@123`
- **Teen Users (with approved parental consent):**
  - `teen1@test.com` / `admin@123`
  - `teen2@test.com` / `admin@123`
- **Adult Users:**
  - `adult1@test.com` / `admin@123`
  - `adult2@test.com` / `admin@123`
- **Admin Users:**
  - `admin1@test.com` / `admin@123`
  - `admin2@test.com` / `admin@123`
- **Moderator Users:**
  - `mod1@test.com` / `admin@123`
  - `mod2@test.com` / `admin@123`

**Sample Organizations:**
- Family Learning Center (min age 5): All users can join
- Teen Innovation Hub (min age 13): Teens and adults only
- Professional Network (min age 18): Adults only

---

## Troubleshooting
- If you see database errors about connections, ensure all Rails servers/consoles are stopped before running db commands.
- If you change model code, restart the Rails server to load changes.
- For issues with parental consent, check the parent email inbox (including spam/junk folders).

---

## Additional Notes
- The app uses Turbo/Hotwire for fast navigation and form handling.
- All participation rules and roles are enforced both in the UI and backend for security.
- Content filtering is automatic and based on the user's age group.
