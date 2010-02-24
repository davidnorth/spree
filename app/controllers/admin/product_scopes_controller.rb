class Admin::ProductScopesController < Admin::BaseController

  resource_controller
  
  belongs_to :product_group
  
  actions :create, :destroy
  
  create.response do |wants| 
    wants.html { redirect_to edit_admin_product_group_path(parent_object) }
    wants.js {}
  end
  destroy.response do |wants| 
    wants.html { redirect_to edit_admin_product_group_path(parent_object) }
    wants.js {}
  end
  
end
