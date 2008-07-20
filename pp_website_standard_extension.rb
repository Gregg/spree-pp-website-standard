# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class PpWebsiteStandardExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/spree_pp_website_standard"

  # define_routes do |map|
  #   map.namespace :admin do |admin|
  #     admin.resources :whatever
  #   end  
  # end
  
  def activate

    Cart.class_eval do
      belongs_to :user
      before_create :create_reference_hash
      
      def create_reference_hash
        self.reference_hash = Digest::SHA1.hexdigest(Time.now.to_s)
      end
    end
    
    # need to make it so the cart page is the only with the paypal button, so we ensure this gets run.
    CartController.class_eval do
      before_filter :set_cart_user
      
      def set_cart_user        
        @cart.user = current_user if logged_in?
      end
    end
    
    # add a PaypalPayment association to the Order model
    Order.class_eval do 
      has_one :paypal_payment
    end
  
  end
  
  def deactivate
    # admin.tabs.remove "Spree Pp Website Standard"
  end
  
end