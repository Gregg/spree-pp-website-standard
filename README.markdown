# Spree Pp Website Standard

Overrides the default Spree checkout process and uses offsite payment processing via PayPal's Website Payment Standard (WPS).  

You'll want to test this using a paypal sandbox account first.  Once you have a business account, you'll want to turn on Instant Payment Notification (IPN).  This is how your application will be notified when a transaction is complete.  Certain transactions aren't completed immediately.  Because of this we use IPN for your application to get notified when the transaction is complete.  IPN means that our application gets an incoming request from Paypal when the transaction goes through.  To turn IPN on in your sandbox account, login, hit "profile", and go to Instant Payment Notification Preferences.  You'll need to turn it on, and point it to your http://www.yourdomain.com/notify.  

Regarding Taxes and shipping, we assumed you'd want to use Paypal's system for this, which can also be configured through the "profile" page.  Taxes have been tested (sales tax), but not shipping, so you may want to give that a test run on the sandbox.

There are also `after_notify` and `after_success` hooks which allow you to implment your own custom logic after the standard processing is performed.  These hooks should be added to `checkout_controller` in the extension you are using for your site specific customizations.

For example:

<pre>
CheckoutController.class_eval do  
  def after_notify(payment)
    # email user and tell them we received their payment
  end
  
  def after_success(payment)
    # email user and thell them that we are processing their order, etc.
  end
end
</pre>



 * TODO: User account creation (if necessary) after notify and associate order with a user
 * TODO: Make the paypal account stuff configurable via new preferences system
 * TODO: Taxes
 * TODO: Shipping
 * TODO: Refunds

# Installation 

<pre>
script/extension install git://github.com/Gregg/spree-pp-website-standard.git  
</pre>