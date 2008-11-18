require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include ActiveMerchant::Billing::Integrations

describe PaypalPaymentsController do
  fixtures :users
  
  before(:each) do 
    @order = Order.create(:id => 100, :number => "SAMP-1001", :total => 75.00)
    @order.state = "in_progress"
    Order.stub!(:find).with(any_args).and_return(@order)
    @ipn = mock("IPN Notification", :invoice => @order.number, :gross => @order.total.to_s, :transaction_id => "TXN1", :fee => "2.00", :currency => "USD", :status => "foo", :received_at => Time.now)
    # mock the parsing of the IPN object since that's just active_merchant functionality that is already tested 
    Paypal::Notification.stub!(:new).with(any_args).and_return(@ipn)
  end
  
  describe "create" do
    
    def do_create
      post :create, :order_id  => @order.id, :payer_email => "test@example.com", :payer_id => "FOO"
    end
    
    before(:each) { @ipn.stub!(:acknowledge).and_return(true) }
    it "should create a paypal payment associated with the order" do    
      do_create
      @order.paypal_payment.should_not be_nil
    end
    it "should set the paypal payment email" do
      do_create
      @order.paypal_payment.email.should == "test@example.com"
    end
    it "should set the paypal payment payer id" do
      do_create
      @order.paypal_payment.payer_id.should == "FOO"
    end
    it "should create a transaction for the paypal payment" do
      do_create
      @order.paypal_payment.txns.first.should_not be_nil
    end
    it "should mark the checkout as complete" do
      do_create
      @order.checkout_complete.should be_true
    end
    # TODO - check that the correct values are being assigned to the transaction

    describe "with acknowledge" do
      before(:each) { @ipn.stub!(:acknowledge).and_return(true) }
      describe "with ipn status completed" do
        before(:each) { @ipn.stub!(:status).and_return("Completed") }
        describe "with matching order total" do
          it "should change the order state to paid" do
            post :create, :order_id  => @order.id
            @order.state.should == "paid"
          end
          it "should set the tax amount" do
            post :create, :order_id  => @order.id, :tax => "1.50"
            @order.tax_amount.should == BigDecimal.new("1.50")
          end
          it "should set the shipping amount" do
            post :create, :order_id  => @order.id, :mc_shipping => "10.75"
            @order.ship_amount.should == BigDecimal.new("10.75")
          end
        end
        it "should change the order status to payment failure when order total does not match" do
          @ipn.stub!(:gross).and_return("1.00")
          @order.total = 20.75
          post :create, :order_id  => @order.id
          @order.state.should == "payment_failure"
        end
      end
      it "should set order status to payment failure when ipn status is not completed" do
        @ipn.stub!(:status).and_return("Foo")
        post :create, :order_id  => @order.id
        @order.state.should == "payment_failure"
      end
    end
    it "should set order status to payment failure if acknowledge is false" do
      @ipn.stub!(:acknowledge).and_return(false)
      post :create, :order_id  => @order.id
      @order.state.should == "payment_failure"
    end
  end  
  
  describe "successful" do
    describe "successful in general", :shared => true do
      def do_successful
        post :successful, :order_id  => @order.id, :mc_gross => @order.total.to_s, :payer_email => "test@example.com", :payer_id => "FOO"
      end
      it "should set the IP address of the order" do
        request.env['REMOTE_ADDR'] = "1.2.3.4"
        do_successful
        @order.ip_address.should == "1.2.3.4"
      end      
      describe "when logged in" do
        before(:each) { @user = login(:pp_standard) }
        it "should store the user with the order" do
          do_successful
          @order.user.should == @user
        end
        it "should redirect to the order details view" do
          do_successful
          response.should redirect_to(order_url(@order))
        end
      end
      it "should redirect to the signup path (if not logged in)" do
        do_successful
        response.should redirect_to(signup_path)
      end
      it "should remove the order from the session" do
        # order should be in the session prior to reaching this controller so we'll simulate that fact
        session[:order_id] = "FOO"
        do_successful
        session[:order_id].should be_nil
      end
    end
    describe "when ipn has not yet been received" do
      it "should create a payment" do
        do_successful
        @order.paypal_payment.should_not be_nil
      end
      it "should set the order status to payment_pending" do
        do_successful
        @order.state.should == "payment_pending"
      end
      it "should mark the checkout as complete" do
        do_successful
        @order.checkout_complete.should be_true
      end
      it "should set the paypal payment email" do
        do_successful
        @order.paypal_payment.email.should == "test@example.com"
      end
      it "should set the paypal payment payer id" do
        do_successful
        @order.paypal_payment.payer_id.should == "FOO"
      end
      it_should_behave_like "successful in general"         
    end
    describe "when ipn has already been received" do
      before(:each) { @order.paypal_payment = PaypalPayment.new }
      it "should not create a new paypal paypment" do
        PaypalPayment.should_not_receive(:create).with(any_args)
        do_successful
      end
      it_should_behave_like "successful in general"  
    end
  end
end