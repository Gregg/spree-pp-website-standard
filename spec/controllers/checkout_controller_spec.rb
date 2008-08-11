require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckoutController do
  describe "/notify" do

    before(:each) do
      @mock_hash = "M0CKH4SH"
      @ipn = mock("IPN Notification", :invoice => @mock_hash, :gross => 50, :null_object => true)
      @ipn.stub!(:acknowledge).and_return(true)
      ActiveMerchant::Billing::Integrations::Paypal::Notification.stub!(:new).with(any_args).and_return @ipn

      @order = mock_model(Order, :null_object => true, :total => 50)

      mock_txns = mock("txns")
      mock_txns.stub!(:build).with(any_args).and_return(mock_model(PaypalTxn))

      @payment = mock_model(PaypalPayment, :txns => mock_txns, :null_object => true)
      PaypalPayment.stub!(:create).with(any_args).and_return(@payment)      
      PaypalPayment.stub!(:find_by_reference_hash).with(@mock_hash).and_return(@payment)      
    end

    describe "notifications in general", :shared => true do
      
      it "should acknowledge the notification" do
        @ipn.should_receive(:acknowledge)
        post :notify
      end
      
      describe "when acknowledgement succeeds" do
        
        before(:each) do
          @ipn.should_receive(:acknowledge).and_return(true)
        end

        describe "when status is completed" do

          before(:each) do
            @ipn.should_receive(:status).at_least(:once).and_return("Completed")
          end

          describe "when the order total is verfied" do 
            before(:each) do
              @order.should_receive(:total).and_return(@ipn.gross)
            end
            it "should change the order status to paid if total is verifed" do
              @order.should_receive(:status=).with(Order::Status::PAID)
              post :notify
            end          
            it "should call the notify hook" do
              @order.stub!(:status).and_return(Order::Status::PAID)
              @controller.should_receive(:after_notify).with(@payment)
              post :notify
            end
          end
          
          describe "when the order total is not verified" do      
            before(:each) do
              @order.should_receive(:total).twice.and_return(1)
            end
            it "should change the order status to incomplete" do
              @order.should_receive(:status=).with(Order::Status::INCOMPLETE)
              post :notify
            end
            it "should not call the notify hook" do
              @order.stub!(:status).and_return(Order::Status::INCOMPLETE)
              @controller.should_not_receive(:after_notify).with(@payment)
              post :notify
            end
          end
        end
        
        describe "when status is pending" do

          before(:each) do
            @ipn.should_receive(:status).at_least(:once).and_return("Pending")
          end

          it "should change the order status to pending payment" do
            @order.should_receive(:status=).at_least(:once).with(Order::Status::PENDING_PAYMENT)
            post :notify
          end
          it "should not call the notify hook" do
            @order.stub!(:status).and_return(Order::Status::PENDING_PAYMENT)
            @controller.should_not_receive(:after_notify).with(@payment)
            post :notify
          end
        end
      end

      describe "when acknowledgement fails" do
        
        before(:each) do
          @ipn.should_receive(:acknowledge).and_return(true)
        end
        
        it "should change the order status to incomplete" do
          @order.should_receive(:status=).with(Order::Status::INCOMPLETE)
          post :notify
        end
        it "should not call the notify hook" do
          @order.stub!(:status).and_return(Order::Status::INCOMPLETE)
          @controller.should_not_receive(:after_notify).with(@payment)
          post :notify
        end
      end
    end
    
    describe "before success" do
      
      before :each do
        @cart = mock_model(Cart, :null_object => true)
        Cart.stub!(:find_by_reference_hash).with(any_args).and_return(@cart)
        Order.stub!(:new_from_cart).with(any_args).and_return(@order)  
      end
      
      it "should locate the cart using the reference hash" do
        Cart.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(@cart)
        post :notify
      end
      
      it "should create an order from the cart" do
        Order.should_receive(:new_from_cart).with(@cart).and_return(@order)
        post :notify
      end
      
      it "should create a payment for the order" do
        expected_payment_params = {:reference_hash => @mock_hash}
        PaypalPayment.should_receive(:create).with(expected_payment_params).and_return(@payment)
        post :notify
      end
      
      it "should associate the payment with the order" do
        @order.should_receive(:paypal_payment=).with(@payment)
        post :notify
      end
      
      it "should destroy the cart" do
        @cart.should_receive(:destroy)
        post :notify
      end
      
      it_should_behave_like "notifications in general"
    end
    
    describe "after success" do
      
      before :each do
        Cart.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(nil)
        @payment.should_receive(:order).and_return(@order)
      end
      
      it "should find the payment using the reference hash" do
        PaypalPayment.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(@payment)
        post :notify
      end
      
      it_should_behave_like "notifications in general"
    end
    

  end

  describe "/success" do
    
    before(:each) do
      @mock_hash = "M0CKH4SH"
      #@ipn = mock("IPN Notification", :invoice => @mock_hash, :gross => 50, :null_object => true)
      #@ipn.stub!(:acknowledge).and_return(true)
      #ActiveMerchant::Billing::Integrations::Paypal::Notification.stub!(:new).with(any_args).and_return @ipn

      @order = mock_model(Order, :null_object => true, :total => 50)

      mock_txns = mock("txns")
      mock_txns.stub!(:build).with(any_args).and_return(mock_model(PaypalTxn))

      @payment = mock_model(PaypalPayment, :txns => mock_txns, :null_object => true)
      PaypalPayment.stub!(:create).with(any_args).and_return(@payment)      
      PaypalPayment.stub!(:find_by_reference_hash).with(@mock_hash).and_return(@payment)      
    end
    
    describe "success in general", :shared => true do      
      it "should call the notify hook" do
        @controller.should_receive(:after_success).with(@payment)
        get :success, {:mc_gross => 50, :invoice => @mock_hash}
      end      
    end
    
    describe "before notify" do      
      before :each do
        @cart = mock_model(Cart, :null_object => true)
        Cart.stub!(:find_by_reference_hash).with(any_args).and_return(@cart)
        Order.stub!(:new_from_cart).with(any_args).and_return(@order)  
      end
      
      it "should locate the cart using the reference hash" do
        Cart.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(@cart)
        get :success, {:mc_gross => 50, :invoice => @mock_hash}
      end
      
      it "should create an order from the cart" do
        Order.should_receive(:new_from_cart).with(@cart).and_return(@order)
        get :success, {:mc_gross => 50, :invoice => @mock_hash}
      end
      
      it "should create a payment for the order" do
        expected_payment_params = {:reference_hash => @mock_hash}
        PaypalPayment.should_receive(:create).with(expected_payment_params).and_return(@payment)
        get :success, {:mc_gross => 50, :invoice => @mock_hash}
      end
      
      it "should associate the payment with the order" do
        @order.should_receive(:paypal_payment=).with(@payment)
        get :success, {:mc_gross => 50, :invoice => @mock_hash}
      end
      
      it "should destroy the cart" do
        @cart.should_receive(:destroy)
        get :success, {:mc_gross => 50, :invoice => @mock_hash}
      end
      
      it_should_behave_like "success in general"
    end
    
    describe "after notify" do
      
      it "should find the payment using the reference hash" do
        Cart.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(nil)
        PaypalPayment.should_receive(:find_by_reference_hash).with(@mock_hash).and_return(@payment)
        @payment.should_receive(:order).and_return(@order)
        get :success, {:mc_gross => 50, :invoice => @mock_hash}
      end
      
      it_should_behave_like "success in general"
    end
    
  end
end