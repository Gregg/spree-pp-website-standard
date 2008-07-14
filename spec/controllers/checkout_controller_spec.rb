require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckoutController do
  describe "/notify" do

    describe "notifications in general", :shared => true do
      
      before(:each) do
        @notification = mock("IPN Notification")
        ActiveMerchant::Billing::Integrations::Paypal::Notification.stub!(:new).with(any_args).and_return @notification
      end
      
      it "should acknowledge the notification" do
        @notification.should_receive(:acknowledge)
        post :notify
      end
      
      describe "when acknowledgement succedes" do
        
        before(:each) do
          @notification.should_receive(:acknowledge).and_return(true)
        end

        describe "when status is completed" do
          # TODO - add more specs here
        end
        describe "when status is pending" do
          # TODO - add more specs here
        end
      end

      describe "when acknowledgement fails" do
        
        before(:each) do
          @notification.should_receive(:acknowledge).and_return(true)
        end
        
        it "should create an error transaction"
        it "should change the order status to ________"
        it "should save the order"
      end
    end
    
    describe "before return" do
      it "should locate the cart using the reference hash"
      it "should create an order from the cart"
      it "should create a payment for the order"
      it "should remove the cart from the session"
      it "should destroy the cart"
      it_should_behave_like "notifications in general"
    end
    
    describe "after return" do
      it "should find the order using the reference hash"
      it_should_behave_like "notifications in general"
    end
    

  end
end