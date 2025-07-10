class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.text :participation_rules
      t.jsonb :analytics

      t.timestamps
    end
  end
end
