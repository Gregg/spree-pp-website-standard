map.resources :orders do |order|
  # we're kind of abusing the notion of a restful collection here but we're in the weird position of 
  # not being able to create the payment before sending the request to paypal
  order.resources :paypal_payments, :collection => {:successful => :post}
end