# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PromotionsExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/promotions"

  def activate

    Order.class_eval do
      has_many :promotion_credits, :extend => Order::Totaling, :order => :position
    end

  end
end
