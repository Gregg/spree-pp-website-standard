# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class SpreePpWebsiteStandardExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/spree_pp_website_standard"

  # define_routes do |map|
  #   map.namespace :admin do |admin|
  #     admin.resources :whatever
  #   end  
  # end
  
  def activate
    # admin.tabs.add "Spree Pp Website Standard", "/admin/spree_pp_website_standard", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Spree Pp Website Standard"
  end
  
end