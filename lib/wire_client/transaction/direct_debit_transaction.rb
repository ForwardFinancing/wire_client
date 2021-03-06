require_relative './transaction'

module WireClient
  class DirectDebitTransaction < Transaction

    attr_accessor :mandate_id,
                  :mandate_date_of_signature,
                  :local_instrument,
                  :sequence_type,
                  :creditor_account,
                  :original_debtor_account,
                  :same_mandate_new_debtor_agent,
                  :service_priority,
                  :service_level

    validates_with MandateIdentifierValidator,
                   field_name: :mandate_id,
                   message: "%{value} is invalid"
    validates_presence_of :mandate_date_of_signature
    validates_inclusion_of :local_instrument, in: LOCAL_INSTRUMENTS
    validates_inclusion_of :sequence_type, in: SEQUENCE_TYPES
    validates_inclusion_of :service_priority, :in => SERVICE_PRIORITY_TYPES
    validates_inclusion_of :service_level, :in => SERVICE_LEVEL_TYPES

    validate do |t|
      t.validate_requested_date_after(WireClient.today.next)
    end

    validate do |t|
      if creditor_account && !creditor_account.valid?
        errors.add(:creditor_account, 'is not correct')
      end

      if t.mandate_date_of_signature.is_a?(Date)
        if t.mandate_date_of_signature > WireClient.today
          errors.add(:mandate_date_of_signature, 'is in the future')
        end
      else
        errors.add(:mandate_date_of_signature, 'is not a Date')
      end
    end

    def initialize(attributes = {})
      super
      @local_instrument ||= 'B2B'
      @sequence_type ||= 'OOFF'
    end
  end
end
