class AddReferenceHash < ActiveRecord::Migration
  def self.up
    add_column :carts, :reference_hash, :string
  end

  def self.down
    remove_column :carts, :reference_hash
  end
end