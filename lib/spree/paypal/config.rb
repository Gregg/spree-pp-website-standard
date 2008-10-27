module Spree
  module Paypal
    # Singleton class to access the Paypal configuration object (PaypalConfiguration.first by default) and it's preferences.
    #
    # Usage:
    #   Spree::Paypal::Config[:foo]                  # Returns the foo preference
    #   Spree::Paypal::Config[]                      # Returns a Hash with all the tax preferences
    #   Spree::Paypal::Config.instance               # Returns the configuration object (PaypalConfiguration.first)
    #   Spree::Paypal::Config.set(preferences_hash)  # Set the tax preferences as especified in +preference_hash+
    class Config
      include Singleton
      include PreferenceAccess
    
      class << self
        def instance
          return nil unless ActiveRecord::Base.connection.tables.include?('configurations')
          PaypalConfiguration.find_or_create_by_name("Default paypal configuration")
        end
      end
    end
  end
end