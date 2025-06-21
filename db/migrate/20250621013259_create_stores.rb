class CreateStores < ActiveRecord::Migration[8.0]
  def change
    create_table :stores do |t|
      t.string :token
      t.string :scope
      t.string :context
      t.timestamps
    end
  end
end
