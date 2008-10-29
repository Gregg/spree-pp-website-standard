class AddEmailField < ActiveRecord::Migration
  def self.up
    change_table :paypal_payments do |t|
      t.string :email
    end
  end

  def self.down
    change_table :paypal_payments do |t|
      t.remove :email
    end
  end
end