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

    context "when shipped" do    
      setup do
        @order = Factory(:order, :state => 'paid')
        @shipment = @order.shipment
        @shipment.update_attribute(:state, 'acknowledged')
      end
      
      should "make order shipped when this is the only shipment" do
        @shipment.ship!
        @order.reload
        assert @order.shipped?
      end
      should "not make order shipped if order has another unshipped shipment" do
        Factory(:shipment, :order => @order)

        @shipment.ship!
        @order.reload
        assert !@order.shipped?
      end
      
      should "set shipped_at" do
        @shipment.ship!
        assert @shipment.shipped_at
      end
    end
    
    context "manifest" do
      setup do
        create_complete_order
          
        @order.line_items.clear
        @variant1 = Factory(:variant)
        @variant2 = Factory(:variant)
        Factory(:line_item, :variant => @variant1, :order => @order, :quantity => 2)
        Factory(:line_item, :variant => @variant2, :order => @order, :quantity => 3)
        @order.reload

        @shipment = @order.shipment        
        @order.complete
      end
      
      should "match the inventory units assigned" do
        assert 2, @shipment.manifest.length
        assert @shipment.manifest.map(&:variant).include?(@variant1)
        assert @shipment.manifest.map(&:variant).include?(@variant2)
        assert_equal 2, @shipment.manifest.detect{|i| i.variant == @variant1}.quantity
        assert_equal 3, @shipment.manifest.detect{|i| i.variant == @variant2}.quantity
      end
      
    end
    
  end

end
