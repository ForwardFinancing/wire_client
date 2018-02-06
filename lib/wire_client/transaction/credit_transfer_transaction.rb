require_relative './transaction'

module WireClient
  class CreditTransferTransaction < Transaction
    attr_accessor :service_priority, :service_level

    validates_inclusion_of :service_priority, :in => SERVICE_PRIORITY_TYPES
    validates_inclusion_of :service_level, :in => SERVICE_LEVEL_TYPES

    validate { |t| t.validate_requested_date_after(Date.today) }

    def initialize(attributes = {})
      super
      self.service_priority ||= 'NORM'
      self.service_level ||= 'URGP'
    end

    def schema_compatible?(_schema_name)
      # Could be used to implement schema_compatibility check
      true
    end
  end
end
