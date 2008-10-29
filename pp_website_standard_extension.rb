# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

unless RAILS_ENV == 'production'
  PAYPAL_ACCOUNT = 'joe@bidness.com'
  ActiveMerchant::Billing::Base.mode = :test
else
  PAYPAL_ACCOUNT = 'Gregg@railsenvy.com'
end

class PpWebsiteStandardExtension < Spree::Extension
  version "1.1"
  description "Describe your extension here"
  url "http://yourwebsite.com/spree_pp_website_standard"

  define_routes do |map|
    map.resources :orders, :has_one => [:paypal_payment] 
  end
  
  def activate

    # Add a partial for PaypalPayment txns
    Admin::OrdersController.class_eval do
      before_filter :add_pp_standard_txns, :only => :show
      def add_pp_standard_txns
        @txn_partials << 'pp_standard_txns'
      end
    end

    # add new events and states to the FSM
    fsm = Order.state_machines['state']  
    fsm.events["fail_payment"] = PluginAWeek::StateMachine::Event.new(fsm, "fail_payment")
    fsm.events["pend_payment"] = PluginAWeek::StateMachine::Event.new(fsm, "pend_payment")
    fsm.events["fail_payment"].transition(:to => 'payment_failure')
    fsm.events["pend_payment"].transition(:to => 'payment_pending')

#    OrdersController.class_eval do
#skip_before_filter :verify_authenticity_token      
#      before_filter :verify_authenticity_token, :except => 'notify'
#      before_filter :load_object, :only => [:successful, :notify]
#      include ActiveMerchant::Billing::Integrations
#      include Paypal::PaController
#    end
    
    # add a PaypalPayment association to the Order model
    Order.class_eval do 
      has_one :paypal_payment
    end
  
  end
  
  def deactivate
    # admin.tabs.remove "Spree Pp Website Standard"
  end
  
end