module WireClient
  class BaseValidator < ActiveModel::Validator
    class_attribute :default_field_name

    def extract_field_name_value(record)
      field_name = options[:field_name] || self.class.default_field_name
      value = record.send(field_name).to_s

      [field_name, value]
    end
  end

  class RegexBasedValidators < BaseValidator
    def validate(record)
      field_name, value = extract_field_name_value(record)

      unless value.match(self.class::REGEX)
        record.errors.add(field_name, :invalid, message: options[:message])
      end
    end
  end

  class CurrencyValidator < RegexBasedValidators
    REGEX = /\A[A-Z]{3,3}\z/

    self.default_field_name = :currency
  end

  class CountryValidator < RegexBasedValidators
    REGEX = /\A[A-Z]{2,2}\z/

    self.default_field_name = :country
  end

  class CreditorIdentifierValidator < RegexBasedValidators
    REGEX = /\A[a-zA-Z0-9]{1,35}\z/

    self.default_field_name = :identifier
  end

  class MandateIdentifierValidator < RegexBasedValidators
    REGEX = /\A([A-Za-z0-9]|[\+|\?|\/|\-|\:|\(|\)|\.|\,|\']){1,35}\z/

    self.default_field_name = :mandate_id
  end

  class CountrySubdivisionValidator < BaseValidator
    self.default_field_name = :country_subdivision

    def validate(record)
      field_name, value = extract_field_name_value(record)
      country = record.send(options[:country] || :country).to_s

      if country == 'US'
        unless (US_STATES.key?(value) || US_STATES.value?(value))
          record.errors.add(field_name, :invalid, message: options[:message])
        end
      end
    end
  end

  class IBANValidator < BaseValidator
    # IBAN2007Identifier (taken from schema)
    REGEX = /\A[A-Z]{2,2}[0-9]{2,2}[a-zA-Z0-9]{1,30}\z/

    self.default_field_name = :iban

    def validate(record)
      field_name, value = extract_field_name_value(record)

      if value.present?
        unless IBANTools::IBAN.valid?(value) && value.match(REGEX)
          record.errors.add(field_name, :invalid, message: options[:message])
        end
      end
    end
  end

  class BICValidator < BaseValidator
    # AnyBICIdentifier (taken from schema)
    REGEX = /\A[A-Z]{6,6}[A-Z2-9][A-NP-Z0-9]([A-Z0-9]{3,3}){0,1}\z/

    self.default_field_name = :bic

    def validate(record)
      field_name, value = extract_field_name_value(record)

      if value.present?
        unless value.match(REGEX)
          record.errors.add(field_name, :invalid, message: options[:message])
        end
      end
    end
  end
end
