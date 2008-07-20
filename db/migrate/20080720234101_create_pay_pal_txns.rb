class CreatePayPalTxns < ActiveRecord::Migration
  def self.up
    create_table :pay_pal_txns do |t|
      t.string :transaction_id
      t.decimal :amount, :precision => 8, :scale => 2
      t.decimal :fee, :precision => 8, :scale => 2
      t.string :currency_type
      t.integer :status
      t.datetime :received_at
      t.timestamps
    end
  end

  def self.down
    drop_table :pay_pal_txns
  end
end
