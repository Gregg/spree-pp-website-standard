class PaypalPayment < ActiveRecord::Base
  has_many :txns, :as => :transactable
  belongs_to :order
  
end
