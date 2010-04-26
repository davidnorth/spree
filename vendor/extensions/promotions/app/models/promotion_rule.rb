# Base class for all promotion rules
class PromotionRule < ActiveRecord::Base

  belongs_to :promotion
  
  def eligible?(order)
    raise 'eligible? should be implemented in a sub-class of Promotion::PromotionRule'
  end

  @rule_classes = nil
  @@rule_classes = Set.new
  def self.register
    @@rule_classes.add(self)
  end

  def self.rule_classes
    @@rule_classes.to_a
  end

end
