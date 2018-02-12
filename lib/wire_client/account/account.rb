require_relative '../base/converters'
require_relative '../base/validators'

module WireClient
  class Account
    include ActiveModel::Validations
    extend Converter

    attr_accessor :name,
                  :iban,
                  :bic,
                  :account_number,
                  :wire_routing_number,
                  :clear_system_code,
                  :schema_code,
                  :identifier,
                  :country,
                  :country_subdivision,
                  :charge_bearer,
                  :currency

    convert :name, to: :text
    validates_length_of :name, within: 1..70
    validates_with CurrencyValidator,
                   CountryValidator,
                   CountrySubdivisionValidator,
                   CreditorIdentifierValidator,
                   BICValidator,
                   IBANValidator,
                   message: "%{value} is invalid"

    def initialize(attributes = {})
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end

      @currency ||= 'USD'
      @country ||= 'US'
      @country_subdivision ||= 'MA'
      @schema_code ||= 'CUST'
      @clear_system_code ||= 'USABA'
      custom_defaults if self.respond_to? :custom_defaults
    end

    def country_subdivision_abbr
      if @country == 'US' && !@country_subdivision.match(/\A[A-Z]{2,2}\z/)
        return US_STATES[@country_subdivision]
      end
      @country_subdivision
    end

    def country_subdivision_name
      if @country == 'US' && @country_subdivision.match(/\A[A-Z]{2,2}\z/)
        return US_STATES.key(@country_subdivision)
      end
      @country_subdivision
    end
  end
end
