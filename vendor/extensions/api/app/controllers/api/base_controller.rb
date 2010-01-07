class Api::BaseController < Spree::BaseController
  require_role 'admin'

  def access_denied
    render :text => 'access_denied', :status => 401
  end

end