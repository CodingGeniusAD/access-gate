class CreateAgeConsents < ActiveRecord::Migration[7.0]
  def change
    create_table :age_consents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :parent_email, null: false
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
