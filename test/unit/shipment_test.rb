require 'test_helper'
class ShipmentTest < ActiveSupport::TestCase

  context "State machine" do
    setup { @shipment = Factory(:shipment) }

    should "be pending initially" do
      assert Shipment.new.pending?
    end
    
    should "change to ready_to_ship when completed" do
      @shipment.complete!
      assert @shipment.ready_to_ship?
    end

  end

end
