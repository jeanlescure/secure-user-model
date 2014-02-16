class CreateGlobalKeys < ActiveRecord::Migration
  def change
    create_table :global_keys do |t|
      t.string :key
      t.text :val

      t.timestamps
    end
    add_index :global_keys, :key
  end
end
