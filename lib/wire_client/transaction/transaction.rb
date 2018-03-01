module WireClient
  class Transaction
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name,
                  :iban,
                  :bic,
                  :account_number,
                  :wire_routing_number,
                  :clear_system_code,
                  :agent_name,
                  :country,
                  :amount,
                  :instruction,
                  :reference,
                  :remittance_information,
                  :requested_date,
                  :batch_booking,
                  :currency,
                  :service_priority,
                  :service_level
    convert :name,
            :instruction,
            :reference,
            :remittance_information, to: :text
    convert :amount, to: :decimal

    validates_length_of :name, within: 1..70
    validates_length_of :currency, is: 3
    validates_length_of :instruction, within: 1..35, allow_nil: true
    validates_length_of :reference, within: 1..35, allow_nil: true
    validates_length_of :remittance_information,
                        within: 1..140,
                        allow_nil: true
    validates_numericality_of :amount, greater_than: 0
    validates_presence_of :requested_date
    validates_inclusion_of :batch_booking, :in => [true, false]
    validates_with CurrencyValidator,
                   CountryValidator,
                   BICValidator,
                   IBANValidator,
                   message: "%{value} is invalid"

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end

      @currency ||= 'USD'
      @country ||= 'US'
      @clear_system_code ||= 'USABA'
      @agent_name ||= 'NOTPROVIDED'
      @requested_date ||= default_requested_date
      @reference ||= 'NOTPROVIDED'
      @batch_booking = true if @batch_booking.nil?
      @service_priority ||= 'NORM'
      @service_level ||= 'URGP'
    end

    def error_messages
      errors.full_messages.join("\n")
    end

    def schema_compatible?(_schema_name)
      # By default, transactions are compatible with any `schema_name`.
      # Could be used to implement schema compatibility check.
      true
    end

    protected

    def default_requested_date
      WireClient.today.freeze
    end

    def validate_requested_date_after(min_requested_date)
      return unless requested_date.is_a?(Date)

      if requested_date != default_requested_date &&
         requested_date < min_requested_date
        errors.add(
          :requested_date,
          "must be greater or equal to #{min_requested_date}, or nil"
        )
      end
    end
  end
end
