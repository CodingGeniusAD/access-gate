class CreateContents < ActiveRecord::Migration[8.0]
  def change
    create_table :contents do |t|
      t.string :title
      t.text :body
      t.string :content_type
      t.integer :age_group

      t.timestamps
    end
  end
end
