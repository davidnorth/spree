# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ApiExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/api"

  # Please use api/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate

    User.class_eval do

      def clear_api_key!
        self.update_attribute(:api_key, "")
      end
      
      def generate_api_key!
        self.update_attribute(:api_key, secure_digest(Time.now, (1..10).map{ rand.to_s }))
      end

      private      
      
      def secure_digest(*args)
        Digest::SHA1.hexdigest(args.flatten.join('--'))
      end

    end
    
  end
end
