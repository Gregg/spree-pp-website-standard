class CheckoutController < Spree::BaseController
  
  # You can send in test notifications on the developer page here:
  # https://developer.paypal.com/us/cgi-bin/devscr?cmd=_ipn-link-session
  def notify
    # notify = Paypal::Notification.new(request.raw_post)

    # if there is a cart record with a reference_hash that matches "invoice"=>"fe130c554f6497a65de238b483c3a3754676a43d"
      # begin transaction
        # Create an order from the cart (include the user if cart has one)
        # Create a payment for the order
        # Remove the cart from the session
        # Destroy the cart (optimistic locking for the cart in case notify is racing us)
      # end transaction
    # else
      # return must have come in first
      # find the order
    # end
    
    # if notify.acknowledge
      #begin
      #  case notify.status
      #  when "Completed" 
      #    
      #    
      #  when "Pending" 
      #    
      #    
      #  else
      #    logger.error("Failed to verify Paypal's notification, please investigate")
      #  end
      #ensure
      #  save order
    # else
      # log error
      # create an error transaction
      # change order status
      # save order and transaction
    # end
    
    # call notify hook (which will email users, etc.)
  end
  
  # When they've returned from paypal
  def return
    
    # if there is a cart record with a reference_hash that matches "invoice"=>"fe130c554f6497a65de238b483c3a3754676a43d"
      # begin transaction
        # Create an order from the cart
        # Create a payment for the order
        # Remove the cart from the session
        # Destroy the cart (optimistic locking for the cart in case notify is racing us)
      # end transaction
    # else (notify must have come in first)
      # Find the order
    # end

    # Add a transaction to the payment to record the information posted in the return 
    # save order and transaction 
    
    # Call the return hook (Application specific email, flash messages and redirects.)    

    # Render thank you (unless redirected by hook of course)
  end
  
end