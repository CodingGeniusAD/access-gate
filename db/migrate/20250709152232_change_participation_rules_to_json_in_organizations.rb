class ChangeParticipationRulesToJsonInOrganizations < ActiveRecord::Migration[8.0]
  def up
    # Convert text to jsonb, preserving existing data as a string in a JSON array
    change_column :organizations, :participation_rules, :jsonb, using: "to_jsonb(participation_rules)"
  end

  def down
    change_column :organizations, :participation_rules, :text
  end
end
