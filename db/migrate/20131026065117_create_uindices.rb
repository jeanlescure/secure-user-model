class CreateUindices < ActiveRecord::Migration
  def change
    create_table :uindices, :id => false, :primary_key => :uid do |t|
      t.string :uid,  :null => false
      t.string :xid,  :null => false

      t.timestamps
    end
    
    add_index :uindices, [:uid], :unique => true
    add_index :uindices, [:xid], :unique => true
  end
end
