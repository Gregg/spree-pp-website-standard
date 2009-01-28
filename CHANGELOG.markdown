0.5.x
-----

* `checkout_controller` is obsolete now that Spree has been refactored to use REST.
* `after_notify` and `after_success` hooks are gone.  See the `README` for how to implement them as hooks in the  "fat" order model.

0.6.x
-----

* Significant database changes, do not run migrations until you have backed up your payment data.
* Migrations will not port over your old payments, its suggested you write your own migration to do this in order to preserve legacy payments.