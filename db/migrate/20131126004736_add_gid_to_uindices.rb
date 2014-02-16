class AddGidToUindices < ActiveRecord::Migration
  def change
    add_column :uindices, :gid, :string
    add_index :uindices, :gid
  end
end
