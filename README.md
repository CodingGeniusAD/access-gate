# AccessGate

A Rails 8 application for organization-based access control, age-based participation, and parental consent workflows.

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

## Development Notes
- **Parental Consent:** Users under 18 must provide a parent email and receive approval before participating.
- **Organization Participation Rules:** Organizations can restrict membership by age and other criteria (see seeds.rb for examples).
- **Turbo/Hotwire:** The app uses Turbo for fast navigation and form handling.
- **Content Filtering:** Basic content filtering is enabled for age groups.

## Troubleshooting
- If you see database errors about connections, ensure all Rails servers/consoles are stopped before running db commands.
- If you change model code, restart the Rails server to load changes.

## Testing
- (Add instructions here if you have tests)

## License
- (Add license info here)
