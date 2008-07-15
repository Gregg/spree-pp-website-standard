require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckoutController do
  describe "/notify" do

    before(:each) do
      @mock_hash = "M0CKH4SH"
      @notification = mock("IPN Notification", :invoice => @mock_hash, :acknowledge => true)
      ActiveMerchant::Billing::Integrations::Paypal::Notification.stub!(:new).with(any_args).and_return @notification
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
        @mock_cart = mock_model(Cart)
        Cart.stub!(:find_by_reference_hash).with(any_args).and_return(@mock_cart)
        @mock_order = mock_model(Order)
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
      
      it "should create a payment for the order"
      it "should remove the cart from the session"
      it "should destroy the cart"
      #it_should_behave_like "notifications in general"
    end
    
    describe "after return" do
      
      before :each do
        Cart.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(nil)
      end
      
      it "should find the order using the reference hash"
      it_should_behave_like "notifications in general"
    end
    

  end
end