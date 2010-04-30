class Promotion::Rules::User < PromotionRule
  belongs_to :user
  
  def eligible?(order)
    order.user == user
  end


  def user_ids_string
    ''
  end
  def user_ids_string=(s)
  end

end