# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PromotionsExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/promotions"

  def activate

    Order.class_eval do
      has_many :promotion_credits, :extend => Order::Totaling, :order => :position
      def products
        line_items.map {|li| li.variant.product}
      end
    end
    
    [Promotion::Rules::ItemTotal, Promotion::Rules::Product, Promotion::Rules::User, Promotion::Rules::FirstOrder].each &:register

    [Calculator::FreeShipping].each(&:register)

  end
end
