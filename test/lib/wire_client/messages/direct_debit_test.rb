require 'test_helper'

describe WireClient::DirectDebit do
  let :message_id_regex do
    /WIRE\/[0-9a-z_]{10}/
  end

  let :direct_debit_message do
    WireClient::DirectDebit.new(
      name: 'Finance institution',
      identifier: 'FINANCEINSTITUTIONID'
    )
  end

  let :transaction_one do
    {
      name: 'Some Merchant',
      bic: 'SPUEDE2UXXX',
      iban: 'DE21500500009876543210',
      mandate_date_of_signature: Date.new(2016,8,11),
      mandate_id: 'K-02-2011-12345',
      amount: 102.50
    }
  end

  let :transaction_two do
    {
      name: 'Some Merchant',
      bic: 'SPUEDE2UXXX',
      iban: 'DE21500500009876543210',
      mandate_date_of_signature: Date.new(2016,8,11),
      mandate_id: 'K-02-2011-12345',
      amount: 202.50
    }
  end

  subject do
    direct_debit_message.add_transaction(transaction_one)
    direct_debit_message.add_transaction(transaction_two)
    direct_debit_message
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

  describe :batches do
    it 'should return an array of batch ids in the message' do
      subject = direct_debit_message
      subject.add_transaction(
        transaction_one.merge(reference: 'EXAMPLE REFERENCE 1'))
      subject.add_transaction(
        transaction_one.merge(
          reference: 'EXAMPLE REFERENCE 2',
          requested_date: Date.today.next.next))
      subject.add_transaction(transaction_two.merge(
        reference: 'EXAMPLE REFERENCE 3'))
      assert_equal subject.batches.size, 2
      assert_match /#{message_id_regex}\/[0-9]+/, subject.batches[0]
      assert_match /#{message_id_regex}\/[0-9]+/, subject.batches[1]
    end
  end

  describe :batch_id do
    it 'should return the batch id where the given transactions belongs to' do
      subject = direct_debit_message
      subject.add_transaction(
        transaction_one.merge(reference: 'EXAMPLE REFERENCE'))
      assert_match /#{message_id_regex}\/1/,
                   subject.batch_id('EXAMPLE REFERENCE')
    end

    it 'should return the batch id where the given transactions belongs to' do
      subject = direct_debit_message
      subject.add_transaction(
        transaction_one.merge(reference: 'EXAMPLE REFERENCE 1'))
      subject.add_transaction(
        transaction_two.merge(
          reference: 'EXAMPLE REFERENCE 2',
          requested_date: Date.today.next.next))
      subject.add_transaction(
        transaction_two.merge(reference: 'EXAMPLE REFERENCE 3'))
      assert_match /#{message_id_regex}\/1/,
                   subject.batch_id('EXAMPLE REFERENCE 1')
      assert_match /#{message_id_regex}\/2/,
                   subject.batch_id('EXAMPLE REFERENCE 2')
    end
  end

  describe 'validation' do
    it 'should not mix local_instrument in transactions' do
      subject = direct_debit_message
      subject.add_transaction(transaction_one.merge(local_instrument: 'CORE'))
      subject.add_transaction(transaction_two.merge(local_instrument: 'B2B'))
      refute subject.valid?
      assert_equal subject.errors[:base].size, 1
    end
  end
end
