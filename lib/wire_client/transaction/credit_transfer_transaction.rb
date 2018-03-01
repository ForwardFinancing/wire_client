require_relative './transaction'

module WireClient
  class CreditTransferTransaction < Transaction
    attr_accessor :service_priority, :service_level

    validates_inclusion_of :service_priority, :in => SERVICE_PRIORITY_TYPES
    validates_inclusion_of :service_level, :in => SERVICE_LEVEL_TYPES

    validate do |t|
      t.validate_requested_date_after(WireClient.today.next)
    end

    def initialize(attributes = {})
      super
      @service_priority ||= 'NORM'
      @service_level ||= 'URGP'
    end
  end
end
