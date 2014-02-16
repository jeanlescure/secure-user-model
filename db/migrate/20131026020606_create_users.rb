class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login,  :null => false
      t.string :salt,  :null => false
      t.text :user,  :null => false

      t.timestamps
    end
    add_index :users, :login, :unique => true
  end
end
