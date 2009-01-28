class RefactorPaymentsAsSti < ActiveRecord::Migration
  def self.up                   
    change_table :payments do |t|
      t.string :email
      t.string :payer_id
    end
    drop_table :paypal_payments    
  end

  def self.down 
    # No going back!
  end
end