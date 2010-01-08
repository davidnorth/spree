class Api::OrdersController < Api::BaseController
  resource_controller_for_api
  actions :index, :show

  private

    def object_serialization_options
      { :include => [:shipments, :line_items] }
    end

end
