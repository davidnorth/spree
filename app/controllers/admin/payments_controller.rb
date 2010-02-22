class Admin::PaymentsController < Admin::BaseController
  before_filter :load_data
  before_filter :load_amount, :except => :country_changed
  resource_controller
  belongs_to :order
  ssl_required

  update.wants.html { redirect_to edit_object_url }

  def create
    build_object
    load_object

    unless object.valid?
      response_for :create_fails
      return
    end
    
    begin 

      if @order.checkout.state == "complete"
        object.process!
        set_flash :create
        redirect_to collection_path
      else
        #This is the first payment (admin created order)
        until @order.checkout.state == "complete"
          @order.checkout.next!
        end
        flash = t('new_order_completed')
        redirect_to admin_order_url(@order)
      end

    rescue Spree::GatewayError => e
      flash.now[:error] = "#{e.message}"
      response_for :create_fails
    end
  end

  def finalize
    object.finalize!
    redirect_to edit_object_path
  end
  

  private

  def object_params
    if source_params = params.delete(:payment_source)[params[:payment][:payment_method_id]]
      params[:payment][:source_attributes] = source_params
    end
    params[:payment]
  end

  def load_data
    load_object
    @payment_methods = PaymentMethod.available   
    @previous_cards = @order.creditcards.with_payment_profile
    @countries = Country.find(:all).sort
    @shipping_countries = Checkout.countries.sort
    if current_user && current_user.bill_address
      default_country = current_user.bill_address.country
    else
      default_country = Country.find Spree::Config[:default_country_id]
    end
    @states = default_country.states.sort
  end

  def load_amount
    @amount = params[:amount] || @order.total
  end

  def build_object
    @object = model.new(object_params)
    @object.payable = parent_object.checkout
    @payment = @object

    #if @object.class == CreditcardPayment
    #  if current_gateway.payment_profiles_supported? and !params[:card].blank? and params[:card] != 'new'
    #    @object.creditcard = Creditcard.find_by_id(params[:card])
    #  else
    #    @object.creditcard ||= Creditcard.new(:checkout => @object.order.checkout)
    #  end
    #end

    @object
  end

end
