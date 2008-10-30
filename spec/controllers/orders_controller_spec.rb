require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrdersController do
  fixtures :users
  
  before(:each) do 
    @order = Order.create(:id => 102, :number => "SAMP-1002", :state => "paid")
    Order.stub!(:find).with(any_args).and_return(@order)
    @paypal_payment = PaypalPayment.create(:payer_id => "FOOFAH")
    PaypalPayment.stub!(:find).with(any_args).and_return([@paypal_payment])
  end
  
  describe "show" do
    it "should associate the order with the user (once authenticated)" do
puts ">>>>> order.number: #{@order.number}"
      @user = login(:pp_standard)
      post :show, :order_id  => @order.id, :payer_id => "FOOFAH"
      #@order.user.should == users(:pp_standard)
    end
    
  end
end