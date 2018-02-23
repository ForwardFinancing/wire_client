require 'test_helper'

describe WireClient::CreditTransfer do
  subject do
    message = WireClient::CreditTransfer.new(
      name: 'Finance institution',
      identifier: 'FINANCEINSTITUTIONID'
    )
    message.add_transaction(
      name: 'Some Merchant',
      bic: 'SPUEDE2UXXX',
      iban: 'DE21500500009876543210',
      amount: 102.50
    )
    message.add_transaction(
      name: 'Some Merchant',
      bic: 'SPUEDE2UXXX',
      iban: 'DE21500500009876543210',
      amount: 202.50
    )
    message
  end

  describe :initialize do
    it 'should create valid transactions for base classes' do
      assert_equal subject.amount_total, 305.00
      assert subject.valid?
    end
  end

  describe :to_xml do
    it 'should not generate XML for unknown schema' do
      assert_raises(ArgumentError) do
        subject.to_xml('unknown')
      end
    end
  end
end
