require File.dirname(__FILE__) + '/../test_helper'

class ShipmentsApiTest < Test::Unit::TestCase
  context "x" do
    setup do
      @cim_gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
        :login => 'x',
        :password => 'y'
      )
      @country = Factory(:country, :name => "United States", :iso_name => "UNITED STATES", :iso3 => "USA", :iso => "US", :numcode => 840)
      @address = Factory(:address, 
        :firstname => 'John',
        :lastname => 'Doe',
        :address1 => '1234 My Street',
        :address2 => 'Apt 1',
        :city =>  'Washington DC',
        :zipcode => '20123',
        :phone => '(555)555-5555',
        :state_name => 'MD',
        :country => @country
      )
      @address.save!

      @creditcard = Factory(:creditcard, :verification_value => '123', :number => '4242424242424242', :month => 9, :year => Time.now.year + 1, :first_name => 'John', :last_name => 'Doe')
      @checkout = Factory(:checkout, :creditcard => @creditcard, :bill_address => @address, :ship_address => @address)
      @gateway = Gateway::AuthorizeNetCim.create!(:name => 'Authorize.net CIM Gateway')
      @creditcard.reload
    end

    should "build correct options for creating a profile" do
      address_options = { 
        :first_name => 'John',
        :last_name => 'Doe',
        :address1 => '1234 My Street',
        :address2 => 'Apt 1',
        :city     => 'Washington DC',
        :state    => 'MD',
        :zip      => '20123',
        :country  => 'US',
        :phone    => '(555)555-5555'
      }
      creditcard = {
        :number => '4242424242424242',
        :month => "9",
        :year => (Time.now.year + 1).to_s,
        :first_name => 'John',
        :last_name => 'Doe',
        :verification_value => '123'
      }
      options = {:profile => { 
        :merchant_customer_id => "#{@checkout.email}-#{@checkout.id}",
        :payment_profiles => {
          :bill_to => address_options,
          :payment => {:credit_card => @creditcard}
          },
          :ship_to_list => address_options
        }}
      assert_equal options, @gateway.send(:options_for_create_customer_profile, @creditcard, @creditcard.gateway_options)
    end
    
    should "update creditcard with gateway_customer_profile_id and gateway_payment_profile_id" do
    end

  end
end
