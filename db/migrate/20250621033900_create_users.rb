class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :bc_id, null: false
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
    # This is called a composite index
    add_index :users, [ :email_address, :bc_id, :store_id ], unique: true
  end
end
