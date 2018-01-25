module WireClient
  # Abstract Wire transfer provider, which all other provider's inherit from
  class Abstract

    # Base class for sending batched Wire transfer transactions to various providers
    class WireBatch
      # An initiator is an entity that initiates the transfer process; it can be a debtor
      # or a creditor. An receptor, on the other hand, is someone that will fulfilling
      # the transfer, whether receiving or withdrawing the described amount.

      # @return [String] Debtor's or creditor's name for the one initianting the transfer
      class_attribute :initiator_name

      # @return [String] Debtor's or creditor's IBAN (International Bank Account Number) ID
      class_attribute :initiator_iban

      # @return [String] Debtor's or creditor's bank SWIFT Code
      class_attribute :initiator_swift_code

      # @return [String] Only used for Debit transactions, its the creditor's Identifier
      class_attribute :initiator_creditor_identifier

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
      # @param transaction_type [WireClient::TransactionTypes::TransactionType] debit or credit
      def initialize(*arguments)
        args = arguments.extract_options!
        self.class.arguments.each do |param|
          self.instance_variable_set(
            "@#{param}".to_sym,
            args[param]
          )
        end
        if @transaction_type == WireClient::TransactionTypes::Credit
          @sepa_transfer = SEPA::CreditTransfer.new(
            name: self.class.initiator_name,
            bic: self.class.initiator_swift_code,
            iban: self.class.initiator_iban
          )
        elsif @transaction_type == WireClient::TransactionTypes::Debit
          @sepa_transfer = SEPA::DirectDebit.new(
            name: self.class.initiator_name,
            bic: self.class.initiator_swift_code,
            iban: self.class.initiator_iban,
            creditor_identifier: self.class.initiator_creditor_identifier
          )
        else
          raise InvalidWireTransactionTypeError, 'Transactions type cannot be inferred and should be explicitly defined'
        end
      end

      def add_transaction(transaction_options)
        @sepa_transfer.add_transaction(uniform_transaction_options(transaction_options))
      end

      ##
      # Sends the batch to the provider. Useful to check transaction status
      #   before sending any data (consistency, validation, etc.)
      def send_batch
        if @sepa_transfer.valid?
          do_send_batch
        else
          raise InvalidWireTransactionError
        end
      end

      # Implementation of sending the Wire transfer batch to the provider, to be
      #   implemented by the subclass
      def do_send_batch
        raise AbstractMethodError
      end

      private

      def uniform_transaction_options(transaction_options)
        if @transaction_type == WireClient::TransactionTypes::Debit
          [
            [:local_instrument, 'B2B'],
            [:sequence_type, 'OOFF']
          ].each do |key, default_value|
            transaction_options[key] = default_value unless transaction_options[key].present?
          end
        end

        [
          [:receptor_name, :name],
          [:receptor_swift_code, :bic],
          [:receptor_iban, :iban]
        ].each do |origin, destination|
          transaction_options[destination] = transaction_options.delete(origin)
        end
        transaction_options[:currency] = 'USD' unless transaction_options[:currency].present?
        transaction_options
      end
    end
  end
end
