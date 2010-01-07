require File.dirname(__FILE__) + '/../test_helper'

class ShipmentsApiTest < ActionController::IntegrationTest
  include ApiIntegrationHelper
  
  context "shipments" do
    setup { setup_user }

    context "index" do
      context "full list with invalid api key" do
        setup do
          get '/api/shipments', nil, {'X-SpreeAPIKey' => 'invalid'}
        end
        should_respond_with 401
      end
      context "full list" do
        setup do
          get_with_key '/api/shipments'
        end
        should_respond_with :success
      end
    end

    context "show" do
      setup do
        @shipment = Factory(:shipment)
        get_with_key "/api/shipments/#{@shipment.id}"
      end
      should_respond_with :success
    end
    
    context "update" do
      context "with valid attributes" do
        setup do
          @shipment = Factory(:shipment)
          put_with_key "/api/shipments/#{@shipment.id}", {:shipment => {:tracking => 'tracking-code'}}
        end
        should_respond_with :success
        should "update the tracking code" do
          @shipment.reload
          assert_equal 'tracking-code', @shipment.tracking
        end
      end
      context "with invalid attributes" do
        setup do
          @shipment = Factory(:shipment)
          put_with_key "/api/shipments/#{@shipment.id}", {:shipment => {:address_attributes => {:firstname => ''}}}
        end
        should_respond_with 422
      end
    end

  end

end
