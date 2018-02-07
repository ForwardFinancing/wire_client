module WireClient
  class Message
    include ActiveModel::Validations

    attr_reader :account, :grouped_transactions

    validates_presence_of :transactions
    validate do |record|
      record.errors.add(:account, record.account.errors.full_messages) unless record.account.valid?
    end

    class_attribute :account_class, :transaction_class, :xml_main_tag, :known_schemas

    def initialize(account_options={})
      @grouped_transactions = {}
      @account = account_class.new(account_options)
    end

    def add_transaction(options)
      transaction = transaction_class.new(options)
      raise(ArgumentError, transaction.error_messages) unless transaction.valid?
      @grouped_transactions[transaction_group(transaction)] ||= []
      @grouped_transactions[transaction_group(transaction)] << transaction
    end

    def transactions
      grouped_transactions.values.flatten
    end

    # @return [String] xml
    def to_xml(schema_name=self.class.known_schemas.first)
      raise(RuntimeError, errors.full_messages.join("\n")) unless valid?
      raise(RuntimeError, "Incompatible with schema #{schema_name}!") unless schema_compatible?(schema_name)

      builder = Builder::XmlMarkup.new indent: 2
      builder.instruct! :xml
      builder.Document(xml_schema(schema_name)) do
        builder.__send__(self.class.xml_main_tag) do
          build_group_header(builder)
          build_payment_informations(builder)
        end
      end
    end

    def amount_total(selected_transactions=transactions)
      selected_transactions.inject(0) { |sum, t| sum + t.amount }
    end

    def schema_compatible?(schema_name)
      raise(ArgumentError, "Schema #{schema_name} is unknown!") unless self.known_schemas.include?(schema_name)

      transactions.all? { |t| t.schema_compatible?(schema_name) }
    end

    # Set unique identifer for the message
    def message_identification=(value)
      raise(ArgumentError, 'mesage_identification must be a string!') unless value.is_a?(String)

      regex = /\A([A-Za-z0-9]|[\+|\?|\/|\-|\:|\(|\)|\.|\,|\'|\ ]){1,35}\z/
      raise(ArgumentError, "mesage_identification does not match #{regex}!") unless value.match(regex)

      @message_identification = value
    end

    # Get unique identifer for the message (with fallback to a random string)
    def message_identification
      @message_identification ||= "WIRE-CLIENT/#{SecureRandom.hex(11)}"
    end

    # Returns the id of the batch to which the given transaction belongs
    # Identified based upon the reference of the transaction
    def batch_id(transaction_reference)
      grouped_transactions.each do |group, transactions|
        if transactions.select { |transaction| transaction.reference == transaction_reference }.any?
          return payment_information_identification(group)
        end
      end
    end

    def batches
      grouped_transactions.keys.collect { |group| payment_information_identification(group) }
    end

    def error_messages
      errors.full_messages.join("\n")
    end

    private

    # @return {Hash<Symbol=>String>} xml schema information used in output xml
    def xml_schema(schema_name)
      {
        :xmlns                => "urn:iso:std:iso:20022:tech:xsd:#{schema_name}",
        :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => "urn:iso:std:iso:20022:tech:xsd:#{schema_name} #{schema_name}.xsd"
      }
    end

    def build_group_header(builder)
      builder.GrpHdr do
        builder.MsgId(message_identification)
        builder.CreDtTm(Time.now.iso8601)
        builder.NbOfTxs(transactions.length)
        builder.CtrlSum('%.2f' % amount_total)
        builder.InitgPty do
          builder.Nm(account.name)
          builder.Id do
            builder.OrgId do
              builder.Othr do
                builder.Id(account.identifier)
              end
            end
          end
        end
      end
    end

    # Unique and consecutive identifier (used for the <PmntInf> blocks)
    def payment_information_identification(group)
      "#{message_identification}/#{grouped_transactions.keys.index(group) + 1}"
    end

    # Returns a key to determine the group to which the transaction belongs
    def transaction_group(transaction)
      transaction
    end

    def account_agent_id(builder, account)
      if account.bic
        builder.BIC(account.bic)
      else
        builder.Othr do
          builder.Id(account.wire_routing_number)
        end
      end
    end

    def account_id(builder, account)
      if account.iban
        builder.IBAN(account.iban)
      else
        builder.Othr do
          builder.Id(account.account_number)
        end
      end
    end

    def transaction_agent_id(builder, transaction)
      if transaction.bic
        builder.BIC(transaction.bic)
      else
        builder.Othr do
          builder.Id(transaction.wire_routing_number)
        end
      end
    end

    def transaction_account_id(builder, transaction)
      if transaction.iban
        builder.IBAN(transaction.iban)
      else
        builder.Othr do
          builder.Id(transaction.account_number)
        end
      end
    end
  end
end
