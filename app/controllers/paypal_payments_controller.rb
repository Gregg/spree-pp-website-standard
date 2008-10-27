class PaypalPaymentsController < Spree::BaseController
#  before_filter :verify_authenticity_token, :except => 'create'

  resource_controller
  belongs_to :order
  #protect_from_forgery :except => [:create, :notify]

  create.before do
debugger    
    puts ">>>>>>>> hello"
    
  end

end