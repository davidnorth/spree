class Api::OrdersController < Api::BaseController
  resource_controller_for_api
  actions :index, :show

  private
  
    def collection
      @search = end_of_association_chain.searchlogic(params[:search])
      @search.order ||= "descend_by_created_at"
      if params[:since_days]
        @search.created_at_greater_than(params[:since_days].to_i.days.ago)
      end
      @collection = @search.all(:limit => 100)
    end

end
