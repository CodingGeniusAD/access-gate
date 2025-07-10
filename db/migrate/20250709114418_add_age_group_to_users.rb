class AddAgeGroupToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :age_group, :integer
  end
end
