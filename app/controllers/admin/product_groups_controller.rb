class Admin::ProductGroupsController < Admin::BaseController
#  before_filter :set_nested_product_scopes, :only => [:create, :update, :preview]
  before_filter :products_submenu

  resource_controller
  
  create.response do |wants| 
    wants.html { redirect_to edit_object_path }
  end
  update.response do |wants| 
    wants.html { redirect_to edit_object_path }
  end
  
  def preview
    @product_group = ProductGroup.new(params[:product_group])
    @product_group.name = "for_preview"
    render :partial => 'preview', :layout => false
  end

  
  private

    def collection
      @search = ProductGroup.searchlogic(params[:search])

      @collection = @search.paginate(
        :per_page => Spree::Config[:per_page],
        :page     => params[:page]
      )
    end

    def set_nested_product_scopes
      result = []
      params[:product_scope].each_pair do |k, v|
        result << {:name => k, :arguments=> v[:arguments]} if v[:active]
      end
      if os = params[:order_scope]
        result << {:name => os, :arguments => []}      
      end
      object && object.product_scopes.clear
      params[:product_group][:product_scopes_attributes] = result
    end

    def products_submenu
      render_to_string :partial => 'admin/shared/product_sub_menu'
    end
  
end
