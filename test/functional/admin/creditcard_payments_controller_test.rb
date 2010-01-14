require 'test_helper'

class Admin::CreditcardPaymentsControllerTest < ActionController::TestCase
  fixtures :gateways

  context "given order" do
    setup do
      UserSession.create(Factory(:admin_user))
      create_new_order
      @order.reload
    end

    context "on POST to :create" do
      setup do
      end

      context "entering a new creditcard" do
        setup do
          @params = {
            :order_id => @order.id, 
            :creditcard => 'new',
            :creditcard_payment => {
              :amount => '2.99',
              :creditcard_attributes => Factory.attributes_for(:creditcard),
              :order_attributes => {
                :checkout_attributes => {
                  :bill_address_attributes => Factory.attributes_for(:address)
                }
              }
            }
          }
          post :create, @params
        end

        should_create :creditcard_payment
        should_respond_with :redirect

        should "create payment with the right attributes" do
          @order.reload
          assert_equal 2, @order.creditcard_payments.count
          assert_equal 2.99, @order.creditcard_payments.last.txns.last.amount.to_f
        end
      end

      context "selected existing creditcard with CIM gateway" do
        setup do
          Gateway.update_all(:active => false)
          gateways(:authorize_net_cim_test).update_attribute(:active, true)
          @params = {
            :order_id => @order.id, 
            :creditcard => @order.creditcards.first.id,
            :creditcard_payment => {
              :amount => '1.99',
            }
          }
          post :create, @params
        end
        #should_create :creditcard_payment
        #should_respond_with :redirect
        
      end

    end


  end
end