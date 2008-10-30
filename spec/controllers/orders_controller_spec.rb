require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrdersController do
  fixtures :users
  
  before(:each) do 
    @order = Order.create(:id => 102)
    # note state is protected attribute so it needs to be set this way
    @order.state = "paid"
    @order.save
    @paypal_payment = PaypalPayment.create(:payer_id => "FOOFAH", :order => @order)
    PaypalPayment.stub!(:find).with(any_args).and_return([@paypal_payment])
  end
  
  describe "show" do
    it "should associate the order with the user (once authenticated)" do
      @user = login(:pp_standard)
      get :show, :order_id  => @order.id, :payer_id => "FOOFAH"
      # check database and make sure the user was set
      order = Order.find @order.id
      order.user.should == @user
    end
    
  end
end