require 'test_helper'

class CreditcardPaymentTest < ActiveSupport::TestCase
  fixtures :gateways

  context "validation" do
    setup do           
      creditcard = Factory(:creditcard, :checkout => Factory(:checkout))
      @payment = Factory(:creditcard_payment, :creditcard => creditcard)
      @auth_amount = @payment.authorization.amount
    end

    context "when amount is positive but exceeds outstanding balance" do
      setup { }
      should "be invalid with error on amount" do
      end
    end

    context "when amount is negative payment but exceeds credit owed" do
      setup { }
      should "be invalid with error on amount" do
      end
    end

    context "when amount is positive and equal to outstanding balance" do
      setup { }
      should "be valid" do
      end
    end

    context "when amount is negative and equal to credit owed" do
      setup { }
      should "be valid" do
      end
    end

  end
end
