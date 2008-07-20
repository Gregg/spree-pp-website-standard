class PayPalTxn < ActiveRecord::Base
  belongs_to :paypal_payment
  validates_numericality_of :amount
end
