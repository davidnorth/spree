require 'test_helper'

class PromotionTest < ActiveSupport::TestCase
  should_validate_presence_of :code
  
  context "instance" do
    setup do
      @checkout = Factory(:checkout)
      @promotion = Factory(:promotion)
    end
    
    context "expires_at < now" do
      setup { @promotion.expires_at = Time.now - 1.day }
      should "not be eligible" do
        assert !@promotion.eligible?(Factory(:order))
      end
    end
    
    context "expires_at > now" do
      setup { @promotion.expires_at = Time.now + 1.day }
      should "be eligible" do
        assert @promotion.eligible?(Factory(:order))
      end
    end
    
    context "with usage limit of 1" do
      setup { @promotion.usage_limit = 1 }
      context "when coupon has already been used" do
        setup { @promotion.create_discount(Factory(:order)) }
        should "not be eligible" do
          assert !@promotion.eligible?(Factory(:order))
        end
      end
      context "when coupon has not yet been used" do
        should "be eligible" do
          assert @promotion.eligible?(Factory(:order))
        end
      end
    end
    
    context "with starts_at > now" do
      setup { @promotion.starts_at = Time.now + 1.day }
      should "not be eligible" do
        assert !@promotion.eligible?(Factory(:order))
      end
    end

    context "with starts_at < now" do
      setup { @promotion.starts_at = Time.now - 1.day }
      should "be eligible" do
        assert @promotion.eligible?(Factory(:order))
      end
    end
    
  end
end