require 'test_helper'

describe WireClient::Message do
  class DummyTransaction < WireClient::Transaction
    def valid?; true end
  end

  class DummyMessage < WireClient::Message
    self.account_class = WireClient::Account
    self.transaction_class = DummyTransaction
  end

  describe :add_transaction do
    class InvalidMessage < WireClient::Message
      self.account_class = WireClient::Account
      self.transaction_class = WireClient::Transaction
    end

    it 'should raise an error when transaction is invalid' do
      message = InvalidMessage.new
      assert_raises(ArgumentError) do
        message.add_transaction amount: 1.1
      end
    end
  end

  describe :to_xml do
    class SchemaIncompatibleTransaction < WireClient::Transaction
      def schema_compatible?(_name); false end

      def valid?; true end
    end

    class SchemaIncompatibleMessage < WireClient::Message
      self.account_class = WireClient::Account
      self.transaction_class = SchemaIncompatibleTransaction
      self.known_schemas = [
        'schema_supported_by_message_but_not_for_transactions'
      ]

      def valid?; true end
    end

    it 'should raise an error if transaction is not compatible with schema' do
      message = SchemaIncompatibleMessage.new
      message.add_transaction({})
      assert_raises(RuntimeError) do
        message.to_xml('schema_supported_by_message_but_not_for_transactions')
      end
    end
  end

  describe :amount_total do
    subject do
      message = DummyMessage.new
      message.add_transaction amount: 1.1
      message.add_transaction amount: 2.2
      message
    end

    it 'should sum up all transactions' do
      assert_equal subject.amount_total, 3.3
    end

    it 'should sum up selected transactions' do
      assert_equal subject.amount_total([subject.transactions[0]]), 1.1
    end
  end

  describe 'validation' do
    subject { DummyMessage.new }

    it 'should fail with invalid account' do
      refute subject.valid?
      assert_equal subject.errors[:account].size, 1
    end

    it 'should fail without transactions' do
      refute subject.valid?
      assert_equal subject.errors[:transactions].size, 1
    end
  end

  describe :message_identification do
    subject { DummyMessage.new }

    describe 'getter' do
      it 'should return prefixed random hex string' do
        assert_match /WIRE([a-f0-9]{2}){5}/, subject.message_identification
      end
    end

    describe 'setter' do
      it 'should accept valid ID' do
        [
          'gid://myMoneyApp/Payment/15108',
          Time.now.to_f.to_s
        ].each do |valid_msgid|
          subject.message_identification = valid_msgid
          assert_equal subject.message_identification, valid_msgid
        end
      end

      it 'should deny invalid string' do
        [ 'my_MESSAGE_ID/123', # contains underscore
          '',                  # blank string
          'üöäß',              # non-ASCII chars
          '1' * 36             # too long
        ].each do |arg|
          assert_raises(ArgumentError) do
            subject.message_identification = arg
          end
        end
      end

      it 'should deny argument other than String' do
        [ 123,
          nil,
          :foo
        ].each do |arg|
          assert_raises(ArgumentError) do
            subject.message_identification = arg
          end
        end
      end
    end
  end
end
