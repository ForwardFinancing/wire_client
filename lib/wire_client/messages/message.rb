module WireClient
  class Message
    include ActiveModel::Validations

    attr_reader :account, :grouped_transactions

    validates_presence_of :transactions
    validate do |record|
      unless record.account.valid?
        record.errors.add(:account, record.account.errors.full_messages)
      end
    end

    class_attribute :account_class,
                    :transaction_class,
                    :xml_main_tag,
                    :known_schemas

    def initialize(account_options={})
      @grouped_transactions = {}
      @account = account_class.new(account_options)
    end

    def add_transaction(options)
      transaction = transaction_class.new(options)
      unless transaction.valid?
        raise ArgumentError, transaction.error_messages
      end
      @grouped_transactions[transaction_group(transaction)] ||= []
      @grouped_transactions[transaction_group(transaction)] << transaction
    end

    def transactions
      grouped_transactions.values.flatten
    end

    # @return [String] xml
    def to_xml(schema_name=self.class.known_schemas.first)
      raise(RuntimeError, errors.full_messages.join("\n")) unless valid?
      unless schema_compatible?(schema_name)
        raise RuntimeError, "Incompatible with schema #{schema_name}!"
      end

      builder = Builder::XmlMarkup.new indent: 2
      builder.instruct! :xml
      builder.Document(xml_schema(schema_name)) do
        builder.__send__(self.class.xml_main_tag) do
          build_group_header(builder)
          build_payment_information(builder)
        end
      end
    end

    def amount_total(selected_transactions=transactions)
      selected_transactions.inject(0) { |sum, t| sum + t.amount }
    end

    def schema_compatible?(schema_name)
      unless self.known_schemas.include?(schema_name)
        raise ArgumentError, "Schema #{schema_name} is unknown!"
      end

      transactions.all? { |t| t.schema_compatible?(schema_name) }
    end

    # Set unique identifer for the message
    def message_identification=(value)
      unless value.is_a?(String)
        raise ArgumentError, 'mesage_identification must be a string!'
      end

      regex = /\A([A-Za-z0-9]|[\+|\?|\/|\-|\:|\(|\)|\.|\,|\'|\ ]){1,35}\z/
      unless value.match(regex)
        raise ArgumentError, "mesage_identification does not match #{regex}!"
      end

      @message_identification = value
    end

    # Get unique identifer for the message (with fallback to a random string)
    def message_identification
      @message_identification ||= "WIRE#{SecureRandom.hex(5)}"
    end

    # Returns the id of the batch to which the given transaction belongs
    # Identified based upon the reference of the transaction
    def batch_id(transaction_reference)
      grouped_transactions.each do |group, transactions|
        selected_transactions = begin
          transactions.select do |transaction|
            transaction.reference == transaction_reference
          end
        end
        if selected_transactions.any?
          return payment_information_identification(group)
        end
      end
    end

    def batches
      grouped_transactions.keys.collect do |group|
        payment_information_identification(group)
      end
    end

    def error_messages
      errors.full_messages.join("\n")
    end

    private

    # @return {Hash<Symbol=>String>} xml schema information used in output xml
    def xml_schema(schema_name)
      urn = "urn:iso:std:iso:20022:tech:xsd:#{schema_name}"
      {
        :xmlns                => "#{urn}",
        :'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => "#{urn} #{schema_name}.xsd"
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
                builder.SchmeNm do
                  builder.Cd(account.schema_code)
                end
              end
            end
          end
        end
      end
    end

    # Unique and consecutive identifier (used for the <PmntInf> blocks)
    def payment_information_identification(group)
      "#{message_identification}#{grouped_transactions.keys.index(group) + 1}"
    end

    # Returns a key to determine the group to which the transaction belongs
    def transaction_group(transaction)
      transaction
    end

    def entity_address(builder, entity)
      builder.StrtNm(entity.address_line)
      builder.PstCd(entity.postal_code)
      builder.TwnNm(entity.city)
      builder.CtrySubDvsn(entity.country_subdivision_abbr)
      builder.Ctry(entity.country)
      builder.AdrLine(entity.address_line)
    end

    def entity_agent_id(builder, entity)
      if entity.bic
        builder.BIC(entity.bic)
      else
        builder.ClrSysMmbId do
          builder.ClrSysId do
            builder.Cd(entity.clear_system_code)
          end
          builder.MmbId(entity.wire_routing_number)
        end
      end
    end

    def account_id(builder, account)
      if account.iban
        builder.Id do
          builder.IBAN(account.iban)
        end
      else
        builder.Id do
          builder.Othr do
            builder.Id(account.account_number)
          end
        end
        builder.Tp do
          builder.Cd('CACC')
        end
        builder.Ccy(account.currency)
      end
    end

    def transaction_account_id(builder, transaction)
      if transaction.iban
        builder.Id do
          builder.IBAN(transaction.iban)
        end
      else
        builder.Id do
          builder.Othr do
            builder.Id(transaction.account_number)
          end
        end
        builder.Tp do
          builder.Cd('CACC')
        end
      end
    end
  end
end
