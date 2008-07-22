class CheckoutController < Spree::BaseController
  
  include ActiveMerchant::Billing::Integrations
  
  # You can send in test notifications on the developer page here:
  # https://developer.paypal.com/us/cgi-bin/devscr?cmd=_ipn-link-session
  def notify
    ipn = Paypal::Notification.new(request.raw_post)

    # Check to see if there is a cart record matching the invoice hash
    if cart = Cart.find_by_reference_hash(ipn.invoice)      
      Order.transaction do
        # Create an order from the cart (include the user if cart has one)
        @order = Order.new_from_cart(cart)
        # Create a payment for the order
        @payment = PaypalPayment.create(:reference_hash => ipn.invoice)
        @order.paypal_payment = @payment
        @order.save
        # Destroy the cart (optimistic locking for the cart in case notify is racing us)
        cart.destroy
      end
    else
      # return must have come in first - so find the payment
      @payment = PaypalPayment.find_by_reference_hash ipn.invoice
      @order = @payment.order
    end
    
    # create a transaction which records the details of the notification
    @payment.txns.build :transaction_id => ipn.transaction_id, :amount => ipn.gross, :fee => ipn.fee, 
      :currency_type => ipn.currency_type, :status => ipn.status, :received_at => ipn.received_at
    @payment.save                    
    
    if ipn.acknowledge
      case ipn.status
      when "Completed" 
        if ipn.gross == @order.total
          @order.status = Order::Status::PAID
        else
          @order.status = Order::Status::INCOMPLETE
          logger.error("Incorrect order total during Paypal's notification, please investigate")
        end
      when "Pending" 
        @order.status = Order::Status::PENDING_PAYMENT
      else
        @order.status = Order::Status::INCOMPLETE
        logger.error("Failed to verify Paypal's notification, please investigate")
      end
    else
      logger.error("Failed to acknowledge Paypal's notification, please investigate.")
      @order.status = Order::Status::INCOMPLETE
    end
    
    @order.save

    # call notify hook (which will email users, etc.)
    after_notify(@payment) if @order.status == Order::Status::PAID
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
  
  def after_notify(payment)
    # override this method in your own custom extension if you wish (see README for details)
  end

  def after_return(payment)
    # override this method in your own custom extension if you wish (see README for details)
  end
  
end