class Promotion < ActiveRecord::Base
  has_many  :promotion_credits,    :as => :adjustment_source
  has_calculator
  alias credits promotion_credits
  
  has_many :promotion_rules

  MATCH_POLICIES = %w(any all)
  preference :match_policy, :string, :default => MATCH_POLICIES.first

  validates_presence_of :code
  
  def eligible?(order)
    # TODO - evalulate rules
    !expired?
  end

  def expired?
    starts_at && Time.now < starts_at ||
    expires_at && Time.now > expires_at || 
    usage_limit && promotion_credits.with_order.count >= usage_limit
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
