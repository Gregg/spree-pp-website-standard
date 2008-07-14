require File.dirname(__FILE__) + '/../spec_helper'

describe PpWebsiteStandardExtension do
  it "should add a PENDING order state if non exists" do
    ORDER_STATES.include?(:pending).should be_true
  end
end