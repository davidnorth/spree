class Admin::CreditcardsController < Admin::BaseController
  resource_controller
  belongs_to :order
  actions :index
  
  def refund
    load_object
    @creditcard_txn = @creditcard.creditcard_txns.find(params[:txn_id])
    @creditcard.credit(params[:amount].to_f, @creditcard_txn)
    redirect_to collection_path
  end
  
end
