require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckoutController do
  describe "/notify" do

    before(:each) do
      @mock_hash = "M0CKH4SH"
      @notification = mock("IPN Notification", :null_object => true)
      @notification.stub!(:invoice).and_return(@mock_hash)
      @notification.stub!(:acknowledge).and_return(true)
      ActiveMerchant::Billing::Integrations::Paypal::Notification.stub!(:new).with(any_args).and_return @notification

      mock_txns = mock("txns")
      mock_txns.stub!(:build).with(any_args).and_return(mock_model(PaypalTxn))
      @mock_payment = mock_model(PaypalPayment, :txns => mock_txns, :null_object => true)
      PaypalPayment.stub!(:create).with(any_args).and_return(@mock_payment)      
      PaypalPayment.stub!(:find_by_reference_hash).with(@mock_hash).and_return(@mock_payment)      
    end

    describe "notifications in general", :shared => true do
      
      before(:each) do
      end
      
      it "should acknowledge the notification" do
        @notification.should_receive(:acknowledge)
        post :notify
      end
      
      describe "when acknowledgement succeeds" do
        
        before(:each) do
          @notification.should_receive(:acknowledge).and_return(true)
        end

        describe "when status is completed" do
          it "should verify the order total"
          it "should change the order status to paid"
          it "should create a transaction to reflect the successful verification"
          it "should save the order"
        end
        describe "when status is pending" do
          it "should verify the order total"
          it "should change the order status to pending payment"
          it "should create a transaction to reflect the pending notification"
          it "should save the order"
        end
      end

      describe "when acknowledgement fails" do
        
        before(:each) do
          @notification.should_receive(:acknowledge).and_return(true)
        end
        
        it "should create an error transaction"
        it "should change the order status to incomplete"
        it "should save the order"
      end
    end
    
    describe "before return" do
      
      before :each do
        @mock_cart = mock_model(Cart, :null_object => true)
        Cart.stub!(:find_by_reference_hash).with(any_args).and_return(@mock_cart)
        @mock_order = mock_model(Order, :null_object => true)
        Order.stub!(:new_from_cart).with(any_args).and_return(@mock_order)  
      end
      
      it "should locate the cart using the reference hash" do
        Cart.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(@mock_cart)
        post :notify
      end
      
      it "should create an order from the cart" do
        Order.should_receive(:new_from_cart).with(@mock_cart).and_return(@mock_order)
        post :notify
      end
      
      it "should create a payment for the order" do
        expected_payment_params = {:reference_hash => @mock_hash}
        PaypalPayment.should_receive(:create).with(expected_payment_params).and_return(@mock_payment)
        post :notify
      end
      
      it "should associate the payment with the order" do
        @mock_order.should_receive(:paypal_payment=).with(@mock_payment)
        post :notify
      end
      
      it "should destroy the cart" do
        @mock_cart.should_receive(:destroy)
        post :notify
      end
      
      it_should_behave_like "notifications in general"
    end
    
    describe "after return" do
      
      before :each do
        Cart.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(nil)
      end
      
      it "should find the payment using the reference hash" do
        PaypalPayment.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(@mock_payment)
        post :notify
      end
      
      it_should_behave_like "notifications in general"
    end
    

  end
end