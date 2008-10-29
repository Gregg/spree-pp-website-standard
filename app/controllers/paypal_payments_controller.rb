class PaypalPaymentsController < Spree::BaseController
  include ActiveMerchant::Billing::Integrations
  
#  before_filter :verify_authenticity_token, :except => 'create'
  layout 'application'
  
  resource_controller :singleton
  belongs_to :order
  #protect_from_forgery :except => [:create, :notify]

  # NOTE: The Paypal Instant Payment Notification (IPN) results in the creation of a PaypalPayment
  create.after do
    ipn = Paypal::Notification.new(request.raw_post)

    # create a transaction which records the details of the notification
    object.txns.create(:transaction_id => ipn.transaction_id, 
                       :amount => ipn.gross, 
                       :fee => ipn.fee,
                       :currency_type => ipn.currency, 
                       :status => ipn.status, 
                       :received_at => ipn.received_at)
    if ipn.acknowledge
      case ipn.status
      when "Completed"
        if ipn.gross.to_d == @order.total
          @order.pay!
          @order.update_attribute("tax_amount", params[:tax].to_d) if params[:tax]
          @order.update_attribute("ship_amount", params[:mc_shipping].to_d) if params[:mc_shipping]          
        else
          @order.fail_payment!
          logger.error("Incorrect order total during Paypal's notification, please investigate (Paypal processed #{ipn.gross}, and order total is #{@order.total})")
        end
      when "Pending"
        @order.fail_payment!
        logger.info("Received an unexpected pending status for order: #{@order.number}")
      else
        @order.fail_payment!
        logger.info("Received an unexpected status for order: #{@order.number}")
      end
    else
      @order.fail_payment!
      logger.info("Failed to acknowledge Paypal's notification, please investigate [order: #{@order.number}]")
    end
=begin    
    @order.save
 
    # call notify hook (which will email users, etc.)
    after_notify(@payment) if @order.status == Order::Status::PAID
=end    
  end

  create.response do |wants|
    wants.html do 
      render :nothing => true    
    end
  end

end