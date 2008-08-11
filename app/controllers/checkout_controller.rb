class CheckoutController < Spree::BaseController
  before_filter :verify_authenticity_token, :except => 'notify'
  
  include ActiveMerchant::Billing::Integrations
  
  # When people hit the checkout button from other pages
  # Bring them to the cart where we have them fill out the form
  def index
    redirect_to :controller => 'cart'
  end
  
  # You can send in test notifications on the developer page here:
  # https://developer.paypal.com/us/cgi-bin/devscr?cmd=_ipn-link-session
  def notify
    ipn = Paypal::Notification.new(request.raw_post)
    @order = find_order(ipn.invoice)

    # create a transaction which records the details of the notification
    @payment.txns.build :transaction_id => ipn.transaction_id, :amount => ipn.gross, :fee => ipn.fee, 
      :currency_type => ipn.currency, :status => ipn.status, :received_at => ipn.received_at
    @payment.save                    
    
    if ipn.acknowledge
      case ipn.status
      when "Completed" 
        if ipn.gross.to_f == @order.total.to_f
          @order.status = Order::Status::PAID
        else
          @order.status = Order::Status::INCOMPLETE
          logger.error("Incorrect order total during Paypal's notification, please investigate (Paypal processed #{ipn.gross}, and order total is #{@order.total})")
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
    
    render :nothing => true
  end
  
  # When they've returned from paypal
  # Not really "success" as in they've paid.  "Success" as in the transaction is in progress
  # Notify is called when the transaction is successfull
  def success
    
    ref_hash = params[:invoice]
    @order = find_order(ref_hash)
    
    # create a transaction for the order (record what little information we have from paypal)
    @payment.txns.build :amount => params[:mc_gross], :status => "order-processed"
    @payment.save                        
    
    # call success hook (which will email users, etc.)
    after_success(@payment)

    # Render thank you (unless redirected by hook of course)
    redirect_to :action => :thank_you, :id => @order.number and return
  end
  
  def after_notify(payment)
    # override this method in your own custom extension if you wish (see README for details)
  end

  def after_success(payment)
    # override this method in your own custom extension if you wish (see README for details)
  end

  def thank_you
    @order = Order.find_by_number(params[:id])
  end
    
  private
  
    def find_order(ref_hash)
      # Check to see if there is a cart record matching the invoice hash
      if cart = Cart.find_by_reference_hash(ref_hash)      
        Order.transaction do          
          # Create an order from the cart (include the user if cart has one)
          @order = Order.new_from_cart(cart)
          @order.status = Order::Status::PENDING_PAYMENT
          @order.number = Order.generate_order_number 
          @order.ip_address =  request.env['REMOTE_ADDR']
          # Create a payment for the order
          @payment = PaypalPayment.create(:reference_hash => ref_hash)
          @order.paypal_payment = @payment
          # Get the tax & shipping
          @order.tax_amount = params[:tax].to_f if params[:tax]
          @order.ship_amount = params[:mc_shipping].to_f if params[:mc_shipping]
          @order.save
          # Destroy the cart (optimistic locking for the cart in case notify is racing us)
          cart.destroy
        end
      else
        # we must have already heard from paypal re: this order
        @payment = PaypalPayment.find_by_reference_hash ref_hash
        @order = @payment.order
      end   
      
      # TODO - replace this temporary hack which zeroes out taxes and shipping
      @order.tax_amount = 0
      @order.ship_amount = 0
      @order.total = @order.item_total
         
      @order
    end
  
end