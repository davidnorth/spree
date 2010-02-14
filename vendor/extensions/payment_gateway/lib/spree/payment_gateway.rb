module Spree
  module PaymentGateway    
    
    def self.included(base)
      base.named_scope :with_payment_profile, :conditions => "gateway_customer_profile_id IS NOT NULL AND gateway_payment_profile_id IS NOT NULL"
      base.after_save :create_payment_profile
    end
    
    def authorize(amount)
      # ActiveMerchant is configured to use cents so we need to multiply order total by 100
      response = payment_gateway.authorize((amount * 100).round, self, gateway_options)      
      gateway_error_from_response(response) unless response.success?
      
      # create a transaction to reflect the authorization
      save
      
      payment.creditcard_txns.create(
        :amount => amount,
        :response_code => response.authorization,
        :txn_type => CreditcardTxn::TxnType::AUTHORIZE,
        :avs_response => response.avs_result['code']
      )
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)      
    end

    def capture(authorization)
      if payment_gateway.payment_profiles_supported?
        # Gateways supporting payment profiles will need access to creditcard object because this stores the payment profile information
        # so supply the authorization itself as well as the creditcard, rather than just the authorization code
        response = payment_gateway.capture(authorization, self, minimal_gateway_options)
      else
        # Standard ActiveMerchant capture usage
        response = payment_gateway.capture((authorization.amount * 100).round, authorization.response_code, minimal_gateway_options)
      end
      gateway_error_from_response(response) unless response.success?          

      # create a transaction to reflect the capture
      save
      payment.creditcard_txns.create(
        :amount => authorization.amount,
        :response_code => response.authorization,
        :txn_type => CreditcardTxn::TxnType::CAPTURE,
        :original_txn => authorization
      )
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)      
    end

    def void(authorization)
      if payment_gateway.payment_profiles_supported?
        response = payment_gateway.credit((authorization.amount * 100).round, self, authorization.response_code, minimal_gateway_options)
      else
        response = payment_gateway.void(authorization.response_code, minimal_gateway_options)
      end      
      gateway_error_from_response(response) unless response.success?

      # create a transaction to reflect the void
      save
      payment.creditcard_txns.create(
        :amount => authorization.amount,
        :response_code => response.authorization,
        :txn_type => CreditcardTxn::TxnType::VOID,
        :original_txn => authorization
      )
    end

    def purchase(amount)
      #combined Authorize and Capture that gets processed by the ActiveMerchant gateway as one single transaction.
      response = payment_gateway.purchase((amount * 100).round, self, gateway_options) 
      
      gateway_error_from_response(response) unless response.success?

      # create a transaction to reflect the purchase
      save
      payment.creditcard_txns.create(
        :amount => amount,
        :response_code => response.authorization,
        :txn_type => CreditcardTxn::TxnType::PURCHASE,
        :avs_response => response.avs_result['code']
      )
    rescue ActiveMerchant::ConnectionError => e
      gateway_error t(:unable_to_connect_to_gateway)
    end
    
    def credit(amount, transaction)
      if payment_gateway.payment_profiles_supported?
        response = payment_gateway.credit((amount * 100).round, self, transaction.response_code, minimal_gateway_options)
      else
        response = payment_gateway.credit((amount * 100).round, transaction.response_code, minimal_gateway_options)
      end
      gateway_error_from_response(response) unless response.success?

      # create a transaction to reflect the purchase
      save
      payment.creditcard_txns.create(
        :amount => -amount,
        :response_code => response.authorization,
        :txn_type => CreditcardTxn::TxnType::CREDIT,
        :original_txn => transaction
      )
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)      
    end
    
    def gateway_error_from_response(response)
      text = response.params['message'] || 
             response.params['response_reason_text'] ||
             response.message
      gateway_error(text)
    end
    
    def gateway_error(text)
      msg = "#{I18n.t('gateway_error')} ... #{text}"
      logger.error(msg)
      raise Spree::GatewayError.new(msg)
    end
        
    def gateway_options
      options = {:billing_address  => generate_address_hash(payment.order.bill_address), 
                 :shipping_address => generate_address_hash(payment.order.shipment.address)}
      options.merge minimal_gateway_options
    end    
    
    # Generates an ActiveMerchant compatible address hash from one of Spree's address objects
    def generate_address_hash(address)
      return {} if address.nil?
      {:name => address.full_name, :address1 => address.address1, :address2 => address.address2, :city => address.city,
       :state => address.state_text, :zip => address.zipcode, :country => address.country.iso, :phone => address.phone}
    end
    
    # Generates a minimal set of gateway options.  There appears to be some issues with passing in 
    # a billing address when authorizing/voiding a previously captured transaction.  So omits these 
    # options in this case since they aren't necessary.  
    def minimal_gateway_options
      {:email    => payment.order.email, 
       :customer => payment.order.email, 
       :ip       => payment.order.ip_address, 
       :order_id => payment.order.number,
       :shipping => payment.order.ship_total * 100,
       :tax      => payment.order.tax_total * 100, 
       :subtotal => payment.order.item_total * 100}  
    end
    
    def spree_cc_type
      return "visa" if ENV['RAILS_ENV'] == "development" 
      self.class.type?(number)
    end

    def payment_gateway
      @payment_gateway ||= Gateway.current
    end  
    
    private
    # TODO: Want to do this after_save but there is a possible danger of infinite loop which number_changed? check is intended to prevent. 
    def create_payment_profile      
      return unless payment_gateway.payment_profiles_supported? and number and number_changed?
      if number_changed?
        payment_gateway.create_profile(self, {})
      end
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
    end

  end
end
