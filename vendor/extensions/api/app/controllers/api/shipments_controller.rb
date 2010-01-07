class Api::ShipmentsController < Api::BaseController
  resource_controller
  actions :index, :show, :update
  
  index.response do |wants|
    wants.json { render :json => collection.to_json(serialization_options) }
    #wants.xml { render :xml => collection.to_xml(serialization_options) }
  end
  
  show.response do |wants|
    wants.json { render :json => object.to_json(serialization_options) }
  end
  
  update do
    wants.json { render :nothing => true }
    failure.wants.json { render :json => object.errors.to_json, :status => 422 }
  end


  private

    def serialization_options
      { :include => {:shipping_method => {}, :address => {}, :inventory_units => {:include => :variant}},
      :except => [:shipping_method_id, :address_id] }
    end
    
    def eager_load_associations
      [:shipping_method, :address, {:inventory_units => [:variant]}]
    end
  
    def collection
      @search = end_of_association_chain.searchlogic(params[:search])
      @search.order ||= "descend_by_created_at"
      if params[:since_days]
        @search.created_at_greater_than(params[:since_days].to_i.days.ago)
      end
      @collection = @search.all(:limit => 100)
    end
    
    def end_of_association_chain
      Shipment.scoped(:include  => eager_load_associations)
    end

end
