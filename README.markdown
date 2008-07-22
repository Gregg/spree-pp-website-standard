# Spree Pp Website Standard

Overrides the default Spree checkout process and uses offsite payment processing via PayPal's Website Payment Standard.  There are also `after_notify` and `after_return` hooks which allow you to implment your own custom logic after the standard processing is performed.  These hooks should be added to `checkout_controller` in the extension you are using for your site specific customizations.

For example:

<pre>
CheckoutController.class_eval do  
  def after_notify(payment)
    # email user and tell them we received their payment
  end
  
  def after_return(payment)
    # email user and thell them that we are processing their order, etc.
  end
end
</pre>

 * TODO: Taxes
 * TODO: Shipping
 * TODO: Refunds

# Installation 

<pre>
script/extension install git://github.com/Gregg/spree-pp-website-standard.git  
</pre>