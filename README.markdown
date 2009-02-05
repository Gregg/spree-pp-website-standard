# Spree Pp Website Standard

Overrides the default Spree checkout process and uses offsite payment processing via PayPal's Website Payment Standard (WPS).  

You'll want to test this using a paypal sandbox account first.  Once you have a business account, you'll want to turn on Instant Payment Notification (IPN).  This is how your application will be notified when a transaction is complete.  Certain transactions aren't completed immediately.  Because of this we use IPN for your application to get notified when the transaction is complete.  IPN means that our application gets an incoming request from Paypal when the transaction goes through.  

__IMPORTANT__
Older versions of this extension mentioned configuring your notify url in the PP profile.  This no longer seems to be necessary, and in fact, if you have previously configured your URL as one that ends in `notify` then you are using an outdated return URL.  Just clear it out.  The notify URL is now being posted with the checkout form and should be sufficient.

Regarding Taxes and shipping, we assumed you'd want to use Paypal's system for this, which can also be configured through the "profile" page.  Taxes have been tested (sales tax), but not shipping, so you may want to give that a test run on the sandbox.

You may want to implement your own custom logic by adding `state_machine` hooks.  Just add these hooks in your site extension (don't change the `pp_website_standard` extension.) Here's an example of how to add the hooks to your site extension.

<pre>
fsm = Order.state_machines['state']  
fsm.after_transition :to => 'paid', :do => :after_payment
fsm.after_transition :to => 'pending_payment', :do => :after_pending  

Order.class_eval do  
  def after_payment
    # email user and tell them we received their payment
  end
  
  def after_pending
    # email user and thell them that we are processing their order, etc.
  end
end
</pre>  
        
# Configuration

Be sure to configure the following configuration parameters.  

Example

<pre>
Spree::Paypal::Config[:account] = "foo@example.com"
Spree::Paypal::Config[:ipn_notify_host] = "http://123.456.78:3000"
Spree::Paypal::Config[:success_url] = "http://localhost:3000/checkout/success"
</pre>

Or even better, you can configure these in a migration for your site extension.

<pre>
class AddPaypalStandardConfigurations < ActiveRecord::Migration
  def self.up
    Spree::Paypal::Config.set(:account => "foo@example.com")
    Spree::Paypal::Config.set(:ipn_notify_host => "http://123.456.78:3000")
    Spree::Paypal::Config.set(:success_url => "http://localhost:3000/checkout/success")
  end

  def self.down
  end
end
</pre>

# Installation 

<pre>
script/extension install git://github.com/Gregg/spree-pp-website-standard.git  
</pre>

# IPN Notes

Real world testing indicates that IPN can be very slow.  If you are wanting to test the IPN piece Paypal now has an IPN tool on their developer site.  Just use the correct URL from the hidden field on your Spree checkout screen.  In the IPN tool, change the transaction type to `cart checkout` and change the `mc_gross` variable to match your order total.

* TODO: Taxes
* TODO: Shipping
* TODO: Refunds
