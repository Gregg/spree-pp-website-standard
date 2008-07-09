class CheckoutController < Spree::BaseController
  
  # You can send in test notifications on the developer page here:
  # https://developer.paypal.com/us/cgi-bin/devscr?cmd=_ipn-link-session
  def notify
    # make sure payment status is successful
    
    # if "payment_status"=>"Completed"
    
          # Look up the cart based on the reference_hash hidden in invoice
          # "invoice"=>"fe130c554f6497a65de238b483c3a3754676a43d"
          # If cart exists, and the "payment_gross"=>"16.99" is the same what the cart says 
          
            # If user is set on cart, 
              # set this on the order
              # send them an email to let them know their order is ready, and they can go to my_account page to get it
            # else
              # grab their paypal email address...   "payer_email"=>"buyer@paypalsandbox.com"
              # Send them an email with a link to the return page below, with the invoice in the url
            # end
          # end
          
     # end
  end
  
  # When they've returned from paypal
  def return
    # Should be sent the invoice information.  "invoice"=>"fe130c554f6497a65de238b483c3a3754676a43d"
    
    # Remove the session cart_id when a user hits this page, but don't try to delete the cart, incase it's waiting to be notified (above)
    
    # If this invoice has already been completed
          # if user is logged in
              # set a flash "Thanks for your order, you can download it below", and send them to their "my_account" page
          # else
              # is the order is associated with a user?
                  # set flash, looks like you just need to login to access your videos
                  # redirect to my accounts page (which will then load login page)
              # else
                  # set flash, "Please just create an account and you can download your heart away"
                  # set session[:return_to] to thir my_account page
                  # redirect to user create form.
              # end
          # end
     # else
        # if user is logged in OR the cart already has a user_id
          # Doesn't look like your payment has been processed quite yet, you should receive an email when it does, or just refresh this page
          # show return.html.erb.. default
        # else 
            # Thanks for your order, it doesn't look like your payment has processed quite yet, please take a moment to create an account
            # so we can let you know when it's done, and so you can have permanent download access to your screencasts
        # end
     # end
  end
  
end