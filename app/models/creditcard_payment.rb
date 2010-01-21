class CreditcardPayment < Payment
  has_many :creditcard_txns
  belongs_to :creditcard
  belongs_to :order
  accepts_nested_attributes_for :creditcard
  accepts_nested_attributes_for :order

  alias :txns :creditcard_txns

  def can_capture?
    txns.present? and txns.last == authorization
  end

  def capture
    return unless can_capture?
    original_auth = authorization
    creditcard.capture(original_auth)
    update_attribute("amount", original_auth.amount)
  end

end