class AddIsOwnerColumn < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_owner, :bool
  end
end
