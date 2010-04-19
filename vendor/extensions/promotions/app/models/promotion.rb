class Promotion < ActiveRecord::Base
  has_many  :promotion_credits,    :as => :adjustment_source
  has_calculator
  alias credits promotion_credits

  validates_presence_of :code
  
  def eligible?(order)
    return false if expires_at and Time.now > expires_at
    return false if usage_limit and promotion_credits.with_order.count >= usage_limit
    return false if starts_at and Time.now < starts_at
    # TODO - also check items in the order (once we support product groups for coupons)
    true
  end

  def create_discount(order)
    return if order.promotion_credits.reload.detect { |credit| credit.adjustment_source_id == self.id }
    if eligible?(order) and amount = calculator.compute(order.line_items)
      amount = order.item_total if amount > order.item_total
      order.promotion_credits.reload.clear unless combine? and order.promotion_credits.all? { |credit| credit.adjustment_source.combine? }
      order.save
      promotion_credits.create({
          :order => order, 
          :description => "#{I18n.t(:coupon)} (#{code})"
        })
    end
  end
end
