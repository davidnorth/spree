class Api::BaseController < Spree::BaseController
  require_role 'admin'

  def access_denied
    render :text => 'access_denied', :status => 401
  end

  # Generic action to handle firing of state events on an object
  def event
    valid_events = model.state_machine.events.map(&:name)
    valid_events_for_object = object.state_transitions.map(&:event)

    if params[:e].blank?
      errors = 'No event specified'
    elsif valid_events_for_object.include?(params[:e].to_sym)
      object.send("#{params[:e]}!")
      errors = nil
    elsif valid_events.include?(params[:e].to_sym)
      errors = "Valid event name but not allowed for this object, allowed events are #{valid_events_for_object.to_sentence}"
    else
      errors = "Invalid event name, valid event names are #{valid_events.to_sentence}"
    end

    respond_to do |wants|
      wants.json do
        if errors.blank?
          render :nothing => true
        else
          render :json => errors.to_json, :status => 422
        end
      end
    end
  end

end