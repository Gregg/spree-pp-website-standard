class AddPayerId < ActiveRecord::Migration
  def self.up
    change_table :paypal_payments do |t|
      t.string :payer_id
    end    
  end

  def self.down
    change_table :paypal_payments do |t|
      t.remove :payer_id
    end    
  end
end