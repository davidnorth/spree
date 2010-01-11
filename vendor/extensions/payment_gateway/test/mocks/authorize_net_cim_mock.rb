module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    # ==== Mock Customer Information Manager (CIM) Gateway
    class AuthorizeNetCimGateway < Gateway
      
      
      def create_customer_profile(options)
        'mock create_customer_profile'
      end
      
    end
  end
end