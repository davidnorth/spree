require File.dirname(__FILE__) + '/../test_helper'

class OrdersApiTest < ActionController::IntegrationTest
  include ApiIntegrationHelper
  
  context "orders" do
    setup do
      setup_user
      @order = Factory(:order)
    end

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
        get_with_key "/api/orders/#{@order.id}"
      end
      should_respond_with :success
    end
    
    context "shipments" do
      context "list" do
        setup do
          get_with_key "/api/orders/#{@order.id}/shipments"
        end
        should_respond_with :success
        should_assign_to :order
        should "only be 1 shipment" do
          assert_equal 1, assigns(:shipments).length
        end
        should "be the shipment that belongs to this order" do
          assert_equal @order, assigns(:shipments).first.order
        end
      end
      context "create" do
        setup do          
          @attributes = {
            :shipment => {
              :shipping_method_id => @order.shipment.shipping_method_id,
              :tracking => 'tracking-code',
              :address_attributes => Factory.attributes_for(:address, :country => nil, :country_id => Factory(:country).id)
              }
            }
          post_with_key "/api/orders/#{@order.id}/shipments", @attributes.to_json
        end
        should_respond_with 201
        should_assign_to :shipment
        should "have correct attributes" do
          assert_equal 'tracking-code', assigns(:shipment).tracking
          assert_equal @attributes[:shipment][:address_attributes][:firstname], assigns(:shipment).address.firstname
        end
      end
    end
  
  end

end
