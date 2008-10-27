class CreatePaypalPayments < ActiveRecord::Migration
  def self.up
    create_table :paypal_payments do |t|
      t.references :order
      t.timestamps
    end
  end

  def self.down
    drop_table :paypal_payments
  end
end
