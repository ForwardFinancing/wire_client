module WireClient
  # Abstract Wire transfer provider, which all other providers inherit from
  class Abstract

    # Base class for sending batched Wire transfer transactions to various
    # providers
    class WireBatch
      # An initiator is an entity that initiates the transfer process; it can
      # be a debtor or a creditor. A receptor, on the other hand, is someone
      # who will fulfill the transfer, whether receiving or withdrawing the
      # described amount.

      # @return [String] Debtor's or creditor's name for the one initianting
      # the transfer
      class_attribute :initiator_name

      # @return [String] Debtor's or creditor's IBAN (International Bank
      # Account Number) ID
      class_attribute :initiator_iban

      # @return [String] Debtor's or creditor's bank SWIFT Code / BIC
      class_attribute :initiator_bic

      # @return [String] Debtor's or creditor's Account Number
      class_attribute :initiator_account_number

      # @return [String] Debtor or creditor agent's wire routing number
      class_attribute :initiator_wire_routing_number

      # @return [String] The initiating party's Identifier
      class_attribute :initiator_identifier

      # @return [String] The initiating party's Postal code (default: NA)
      class_attribute :initiator_postal_code

      # @return [String] The initiating party's Address line (default: NA)
      class_attribute :initiator_address_line

      # @return [String] The initiating party's City, town or municipality
      # (default: NA)
      class_attribute :initiator_city

      # @return [String] The initiating party's country subdivision (name or
      # 2 character code; default: MA)
      class_attribute :initiator_country_subdivision

      # @return [String] The initiating party's country (2 character country
      # code; default: US)
      class_attribute :initiator_country

      ##
      # @return [Array] A list of arguments to use in the initializer, and as
      # instance attributes
      def self.arguments
        [
          :transaction_type
        ]
      end

      attr_reader(*arguments)

      ##
      # @param transaction_type [WireClient::TransactionTypes::TransactionType]
      # debit or credit
      def initialize(*arguments)
        args = arguments.extract_options!
        self.class.arguments.each do |param|
          self.instance_variable_set(
            "@#{param}".to_sym,
            args[param]
          )
        end
        if @transaction_type == WireClient::TransactionTypes::Credit
          initialize_payment_initiation(CreditTransfer)
        elsif @transaction_type == WireClient::TransactionTypes::Debit
          initialize_payment_initiation(DirectDebit)
        else
          raise InvalidWireTransactionTypeError,
                'Transaction type should be explicitly defined'
        end
      end

      def add_transaction(transaction_options)
        @payment_initiation.add_transaction(transaction_options)
      end

      ##
      # Sends the batch to the provider. Useful to check transaction status
      #   before sending any data (consistency, validation, etc.)
      def send_batch
        if @payment_initiation.valid?
          do_send_batch
        else
          raise InvalidWireTransactionError,
                "invalid wire transfer: #{@payment_initiation.error_messages}"
        end
      end

      # Implementation of sending the Wire transfer batch to the provider, to be
      #   implemented by the subclass
      def do_send_batch
        raise AbstractMethodError
      end

      private

      def initialize_payment_initiation(klass)
        if self.class.initiator_iban
          @payment_initiation = klass.new(
            name: self.class.initiator_name,
            bic: self.class.initiator_bic,
            iban: self.class.initiator_iban,
            identifier: self.class.initiator_identifier,
            postal_code: self.class.initiator_postal_code,
            address_line: self.class.initiator_address_line,
            city: self.class.initiator_city,
            country_subdivision: self.class.initiator_country_subdivision,
            country: self.class.initiator_country
          )
        else
          @payment_initiation = klass.new(
            name: self.class.initiator_name,
            wire_routing_number: self.class.initiator_wire_routing_number,
            account_number: self.class.initiator_account_number,
            identifier: self.class.initiator_identifier,
            postal_code: self.class.initiator_postal_code,
            address_line: self.class.initiator_address_line,
            city: self.class.initiator_city,
            country_subdivision: self.class.initiator_country_subdivision,
            country: self.class.initiator_country
          )
        end
      end
    end
  end
end
