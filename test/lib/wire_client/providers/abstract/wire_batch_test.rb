require 'test_helper'

class AbstractProvider
  class WireBatchTest < MiniTest::Test
    def test_abstractfulness
      assert_raises(AbstractMethodError) do
        WireClient::Abstract::WireBatch.new(
          transaction_type: WireClient::TransactionTypes::Credit
        ).do_send_batch
      end

      assert_raises(AbstractMethodError) do
        WireClient::Abstract::WireBatch.new(
          transaction_type: WireClient::TransactionTypes::Debit
        ).do_send_batch
      end
    end

    def test_transactions_validation
      assert_raises(InvalidWireTransactionTypeError) do
        WireClient::Abstract::WireBatch.new(
        ).do_send_batch
      end

      assert_raises(InvalidWireTransactionError) do
        WireClient::Abstract::WireBatch.new(
          transaction_type: WireClient::TransactionTypes::Credit
        ).send_batch
      end
    end
  end
end
