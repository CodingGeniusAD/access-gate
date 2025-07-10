class AddApprovalTokenToAgeConsents < ActiveRecord::Migration[8.0]
  def change
    add_column :age_consents, :approval_token, :string
  end
end
