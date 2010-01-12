class Gateway::AuthorizeNetCim < Gateway
	preference :login, :string
	preference :password, :password
	
  def provider_class
    self.class
  end	

  def authorize(amount, creditcard, gateway_options)

    options = {:billing_address  => generate_address_hash(checkout.bill_address), 
               :shipping_address => generate_address_hash(checkout.shipment.address)}
    options.merge minimal_gateway_options

  end
  
  def purchase(amount, creditcard, gateway_options)
  end

  private

    # Create a new CIM customer profile ready to accept a payment
    def prepare_customer_profile(creditcard, gateway_options)

      response = cim_gateway.create_customer_profile(options)

      if response.success?
        customer_profile_id = response.params["customer_profile_id"]
        customer_payment_profile_id = response.params["customer_payment_profile_id_list"].values.first
        customer_shipping_address_id = response.params["customer_shipping_address_id_list"].values.first
      else
        
      end
      
    end

    def options_for_create_customer_profile(creditcard, gateway_options)
        {:profile => { :merchant_customer_id => "#{creditcard.checkout.email}-#{creditcard.checkout.id}",
          :ship_to_list => generate_address_hash(creditcard.checkout.ship_address),
          :payment_profiles => {
            :bill_to => generate_address_hash(creditcard.checkout.bill_address),
            :payment => { :credit_card => creditcard}
          }
        }}
    end

    # As in PaymentGateway but with separate name fields
    def generate_address_hash(address)
      return {} if address.nil?
      {:first_name => address.firstname, :last_name => address.lastname, :address1 => address.address1, :address2 => address.address2, :city => address.city,
       :state => address.state_text, :zip => address.zipcode, :country => address.country.iso, :phone => address.phone}
    end
    

end
