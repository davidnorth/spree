class Admin::ProductGroupsController < Admin::BaseController
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

    # Consolidate argument arrays for nested product_scope attributes
    def object_params
      if params["product_group"] and params["product_group"]["product_scopes_attributes"].is_a?(Array)
        params["product_group"]["product_scopes_attributes"] = params["product_group"]["product_scopes_attributes"].group_by {|a| a["id"]}.map do |scope_id, attrs| 
          { "id" => scope_id, 
            "arguments" => attrs.map{|a| a["arguments"] }.flatten
          }
        end
      end
      params["product_group"]
    end

    def collection
      @search = ProductGroup.searchlogic(params[:search])

      @collection = @search.paginate(
        :per_page => Spree::Config[:per_page],
        :page     => params[:page]
      )
    end

    def products_submenu
      render_to_string :partial => 'admin/shared/product_sub_menu'
    end
  
end
