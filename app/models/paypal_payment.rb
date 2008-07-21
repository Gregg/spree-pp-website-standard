class PaypalPayment < ActiveRecord::Base
  has_many :paypal_txns
  belongs_to :order
  
  alias :txns :paypal_txns
end
