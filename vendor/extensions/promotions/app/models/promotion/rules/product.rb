# A rule to limit a promotion based on products in the order.
# Can require all or any of the products to be present.
# Valid products either come from assigned product group or are assingned directly to the rule. 
class Promotion::Rules::Product < PromotionRule

  belongs_to :product_group
  has_and_belongs_to_many :products, :class_name => '::Product', :join_table => 'products_promotion_rules', :foreign_key => 'promotion_rule_id'

  MATCH_POLICIES = %w(any all)
  preference :match_policy, :string, :default => MATCH_POLICIES.first

  # scope/association that is used to test eligibility
  def eligible_products
    product_group ? product_group.products : products
  end
    
end