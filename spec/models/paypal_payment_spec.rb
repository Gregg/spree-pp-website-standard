require File.dirname(__FILE__) + '/../spec_helper'

describe PaypalPayment do
  before(:each) do
    @paypal_payment = PaypalPayment.new
  end

  it "should be valid" do
    @paypal_payment.should be_valid
  end
end
