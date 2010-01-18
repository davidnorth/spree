class Gateway::AuthorizeNetCim < Gateway
	preference :login, :string
	preference :password, :password
	
  ActiveMerchant::Billing::Response.class_eval do
    # response.authorization is nil when creating an authorize transaction, instead there's 'approval_code' in params['direct_response']
    # for consistiency with other gateways, this value needs to be assigned to authorization so add the necessary attribute writer
    attr_writer :authorization
  end

  ActiveMerchant::Billing::AuthorizeNetCimGateway.class_eval do

    CIM_TRANSACTION_TYPES = {
      :auth_capture => 'profileTransAuthCapture',
      :auth_only => 'profileTransAuthOnly',
      :capture_only => 'profileTransCaptureOnly',
      :refund => 'profileTransRefund'
    }

    private

    # Simplified implementation of this method because transaction_id wasn't always being set
    def parse_direct_response(response)
      direct_response_fields = response.params['direct_response'].split(',')
      {
        'raw' => response.params['direct_response'],
        'response_code' => direct_response_fields[0],
        'response_subcode' => direct_response_fields[1],
        'response_reason_code' => direct_response_fields[2],
        'message' => direct_response_fields[3],
        'approval_code' => direct_response_fields[4],
        'avs_response' => direct_response_fields[5],
        'transaction_id' => direct_response_fields[6],
        'invoice_number' => direct_response_fields[7],
        'order_description' => direct_response_fields[8],
        'amount' => direct_response_fields[9],
        'method' => direct_response_fields[10],
        'transaction_type' => direct_response_fields[11],
        'customer_id' => direct_response_fields[12],
        'first_name' => direct_response_fields[13],
        'last_name' => direct_response_fields[14],
        'company' => direct_response_fields[15],
        'address' => direct_response_fields[16],
        'city' => direct_response_fields[17],
        'state' => direct_response_fields[18],
        'zip_code' => direct_response_fields[19],
        'country' => direct_response_fields[20],
        'phone' => direct_response_fields[21],
        'fax' => direct_response_fields[22],
        'email_address' => direct_response_fields[23],
        'ship_to_first_name' => direct_response_fields[24],
        'ship_to_last_name' => direct_response_fields[25],
        'ship_to_company' => direct_response_fields[26],
        'ship_to_address' => direct_response_fields[27],
        'ship_to_city' => direct_response_fields[28],
        'ship_to_state' => direct_response_fields[29],
        'ship_to_zip_code' => direct_response_fields[30],
        'ship_to_country' => direct_response_fields[31],
        'tax' => direct_response_fields[32],
        'duty' => direct_response_fields[33],
        'freight' => direct_response_fields[34],
        'tax_exempt' => direct_response_fields[35],
        'purchase_order_number' => direct_response_fields[36],
        'md5_hash' => direct_response_fields[37],
        'card_code' => direct_response_fields[38],
        'cardholder_authentication_verification_response' => direct_response_fields[39]
      }
    end

    # Add the transId tag for refund transactions
    def add_transaction(xml, transaction)
      puts '- Patched add_transaction -'
      unless CIM_TRANSACTION_TYPES.include?(transaction[:type])
        raise StandardError, "Invalid Customer Information Manager Transaction Type: #{transaction[:type]}"
      end

      xml.tag!('transaction') do
        xml.tag!(CIM_TRANSACTION_TYPES[transaction[:type]]) do
          # The amount to be billed to the customer
          xml.tag!('amount', transaction[:amount])
          xml.tag!('customerProfileId', transaction[:customer_profile_id])
          xml.tag!('customerPaymentProfileId', transaction[:customer_payment_profile_id])
          xml.tag!('approvalCode', transaction[:approval_code]) if transaction[:type] == :capture_only
          xml.tag!('transId', transaction[:trans_id]) if transaction[:type] == :refund
          add_order(xml, transaction[:order]) if transaction[:order]
        end
      end
    end

    # Set response authorization to the transaction_id
    def commit(action, request)
      url = test? ? test_url : live_url
      xml = ssl_post(url, request, "Content-Type" => "text/xml")

      response_params = parse(action, xml)

      message = response_params['messages']['message']['text']
      test_mode = test? || message =~ /Test Mode/
      success = response_params['messages']['result_code'] == 'Ok'

      response = ActiveMerchant::Billing::Response.new(success, message, response_params,
        :test => test_mode,
        :authorization => response_params['customer_profile_id'] || (response_params['profile'] ? response_params['profile']['customer_profile_id'] : nil)
      )

      response.params['direct_response'] = parse_direct_response(response) if response.params['direct_response']

      if response.authorization.nil? and response.params['direct_response']
        if !response.params['direct_response']['transaction_id'].blank? and response.params['direct_response']['transaction_id'] != '0'
          response.authorization = response.params['direct_response']['transaction_id']
        end
      end

      response
    end


  end



  def provider_class
    self.class
  end	

  def authorize(amount, creditcard, gateway_options)
    response = create_transaction(amount, creditcard, :auth_only)
    response.authorization = response.params['direct_response']['approval_code']
    response
  end
  
  def purchase(amount, creditcard, gateway_options)
    create_transaction(amount, creditcard, :auth_capture)
  end

  def capture(authorization, creditcard, gateway_options)
    create_transaction((authorization.amount * 100).to_i, creditcard, :capture_only, :approval_code => authorization.response_code)
  end
  
  def capture(amount, transaction, gateway_options)
    create_transaction(amount, transaction.creditcard, :refund)
  end
  
	def payment_profiles_supported?
	  true
  end

  private

    # Create a transaction on a creditcard
    # Set up a CIM profile for the card if one doesn't exist
    # Valid transaction_types are :auth_only, :capture_only and :auth_capture
    def create_transaction(amount, creditcard, transaction_type, options = {})
      if creditcard.gateway_customer_profile_id.nil?
        profile_hash = create_customer_profile(creditcard, creditcard.gateway_options)
        creditcard.update_attributes!(:gateway_customer_profile_id => profile_hash[:customer_profile_id], :gateway_payment_profile_id => profile_hash[:customer_payment_profile_id])
      end
      amount = "%.2f" % (amount/100.0) # This gateway requires formated decimal, not cents
      transaction_options = {
        :type => transaction_type, 
        :amount => amount,
        :customer_profile_id => creditcard.gateway_customer_profile_id,
        :customer_payment_profile_id => creditcard.gateway_payment_profile_id,
      }.update(options)
      cim_gateway.create_customer_profile_transaction(:transaction => transaction_options)
    end
  
    # Create a new CIM customer profile ready to accept a payment
    def create_customer_profile(creditcard, gateway_options)
      options = options_for_create_customer_profile(creditcard, gateway_options)
      response = cim_gateway.create_customer_profile(options)
      if response.success?
        { :customer_profile_id => response.params["customer_profile_id"], 
          :customer_payment_profile_id => response.params["customer_payment_profile_id_list"].values.first }
      else
        creditcard.gateway_error(response)
      end
    end

    def options_for_create_customer_profile(creditcard, gateway_options)
        {:profile => { :merchant_customer_id => "#{Time.now.to_f}",
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

    def cim_gateway
      ActiveMerchant::Billing::Base.gateway_mode = server.to_sym
      gateway_options = options
      gateway_options[:test] = true if test_mode
  		ActiveMerchant::Billing::AuthorizeNetCimGateway.new(gateway_options)
    end 
    
end
