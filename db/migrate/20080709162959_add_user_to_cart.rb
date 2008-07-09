class AddUserToCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :user_id, :integer
  end

  def self.down
    remove_column :carts, :user_id, :integer
  end
end