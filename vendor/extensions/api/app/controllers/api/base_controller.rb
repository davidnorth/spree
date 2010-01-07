class Api::BaseController < Spree::BaseController
  require_role 'admin'

end