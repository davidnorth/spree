class Promotion::Rules::User < PromotionRule
  belongs_to :user
  
  def eligible?(order)
    order.user == user
  end

end