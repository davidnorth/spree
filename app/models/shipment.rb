class Shipment < ActiveRecord::Base        
  belongs_to :order
  belongs_to :shipping_method
  belongs_to :address
  has_one    :shipping_charge,   :as => :adjustment_source
  alias charge shipping_charge
  has_many :state_events, :as => :stateful

  before_create :generate_shipment_number
  after_save :transition_order
  after_save :create_shipping_charge
  
  attr_accessor :special_instructions 
  accepts_nested_attributes_for :address
     
  def shipped?
    self.shipped_at
  end
  
  def shipped=(value)
    return unless value == "1" && shipped_at.nil?
    self.shipped_at = Time.now
  end

  def create_shipping_charge
    if shipping_method
      self.shipping_charge ||= ShippingCharge.create({
          :order => order,
          :description => "#{I18n.t(:shipping)} (#{shipping_method.name})",
          :adjustment_source => self,
        })
    end
  end

  # shipment state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => 'pending' do

    event :complete do
      transition :from => 'pending', :to => 'ready_to_ship'
    end
    event :transmit do
      transition :from => 'ready_to_ship', :to => 'transmitted'
    end
    event :acknowledge do
      transition :from => 'transmitted', :to => 'acknowledged'
    end
    event :reject do
      transition :from => 'acknowledged', :to => 'unable_to_ship'
    end
    event :ship do
      transition :from => 'acknowledged', :to => 'shipped'
    end

  end

  private

  def generate_shipment_number
    record = true
    while record
      random = Array.new(11){rand(9)}.join
      record = Shipment.find(:first, :conditions => ["number = ?", random])
    end
    self.number = random
  end
  
  def transition_order
    # transition order to shipped if all shipments have been shipped
    return unless shipped_at_changed?
    order.shipments.each do |shipment|
      return unless shipment.shipped?
    end
    order.ship!
  end
end
