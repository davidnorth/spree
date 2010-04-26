# A rule to limit a promotion to a specific user.
class Promotion::Rules::ItemTotal < PromotionRule

  preference :amount, :decimal, :default => 100.00
  preference :operator, :string, :default => '>'
  
  OPERATORS = ['>', '>=']

end