require_relative '../base/converters'
require_relative '../base/validators'
require_relative '../base/account_transaction_helpers'

module WireClient
  class Account
    include ActiveModel::Validations
    include AccountTransactionHelpers
    extend Converter

    attr_accessor :name,
                  :iban,
                  :bic,
                  :account_number,
                  :wire_routing_number,
                  :clear_system_code,
                  :postal_code,
                  :address_line,
                  :city,
                  :country_subdivision,
                  :country,
                  :currency,
                  :schema_code,
                  :identifier,
                  :charge_bearer

    convert :name, to: :text
    validates_length_of :currency, is: 3
    validates_length_of :name, within: 1..70
    validates_with CurrencyValidator,
                   CountryValidator,
                   CountrySubdivisionValidator,
                   BICValidator,
                   IBANValidator,
                   CreditorIdentifierValidator,
                   message: "%{value} is invalid"

    def initialize(attributes = {})
      attributes.each do |name, value|
        public_send("#{name}=", value)
      end

      @currency ||= 'USD'
      @postal_code ||= 'NA'
      @address_line ||= 'NA'
      @city ||= 'NA'
      @country ||= 'US'
      @country_subdivision ||= 'MA' if self.country == 'US'
      @schema_code ||= 'CUST'
      @clear_system_code ||= 'USABA'
      custom_defaults if self.respond_to? :custom_defaults
    end
  end
end
