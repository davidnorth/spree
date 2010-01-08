require File.dirname(__FILE__) + '/../test_helper'

class OrdersApiTest < ActionController::IntegrationTest
  include ApiIntegrationHelper
  
  context "orders" do
    setup { setup_user }

    context "index" do
      context "full list" do
        setup do
          get_with_key '/api/orders'
        end
        should_respond_with :success
      end
    end

    context "show" do
      setup do
        @order = Factory(:order)
        get_with_key "/api/orders/#{@order.id}"
      end
      should_respond_with :success
    end
  
  end

end
