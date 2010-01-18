class Admin::CreditcardsController < Admin::BaseController
  resource_controller
  belongs_to :order
  actions :index
  
end
