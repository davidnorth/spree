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

    context "event" do
      setup do
        @shipment = Factory(:shipment)
      end
      context "with event valid for the shipment" do
        setup { put_with_key "/api/shipments/#{@shipment.id}/event?e=ready" }
        should_respond_with :success
        should "update the state" do
          @shipment.reload
          assert @shipment.ready_to_ship?, "shipment wasn't updated to ready_to_ship"
        end
      end
      context "with no event name" do
        setup { put_with_key "/api/shipments/#{@shipment.id}/event?e=" }
        should_respond_with 422
      end
      context "with an invalid event name" do
        setup { put_with_key "/api/shipments/#{@shipment.id}/event?e=foo" }
        should_respond_with 422
      end
      context "with an valid event that isn't allowed on this object" do
        setup { put_with_key "/api/shipments/#{@shipment.id}/event?e=ship" }
        should_respond_with 422
      end
    end


  end

end
