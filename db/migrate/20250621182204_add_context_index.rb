class AddContextIndex < ActiveRecord::Migration[8.0]
  def change
    add_index :stores, :context, unique: true
  end
end
