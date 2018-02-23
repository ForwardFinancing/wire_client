require 'test_helper'

describe WireClient::DirectDebitTransaction do
  describe :initialize do
    it 'should create a valid transaction' do
      subject = WireClient::DirectDebitTransaction.new(
        name: 'Some Merchant',
        wire_routing_number: '111900659',
        agent_name: 'BANK OF AMERICA',
        account_number: '3019586020',
        amount: 102.50,
        reference: 'XYZ-1234/123',
        remittance_information: 'Any information given',
        mandate_id: 'K-02-2011-12345',
        mandate_date_of_signature: Date.new(2011,1,25)
      )
      assert subject.valid?

      subject = WireClient::DirectDebitTransaction.new(
        name: 'Zahlemann & Söhne Gbr',
        bic: 'SPUEDE2UXXX',
        iban: 'DE21500500009876543210',
        amount: 39.99,
        currency: 'EUR',
        reference: 'XYZ-1234/123',
        remittance_information: 'Vielen Dank für Ihren Einkauf!',
        mandate_id: 'K-02-2011-12345',
        mandate_date_of_signature: Date.new(2011,1,25)
      )
      assert subject.valid?
    end

    it 'should have default for local_instrument' do
      assert_equal WireClient::DirectDebitTransaction.new.local_instrument,
                   'B2B'
    end

    it 'should have default for sequence_type' do
      assert_equal WireClient::DirectDebitTransaction.new.sequence_type,
                   'OOFF'
    end
  end

  describe 'validation' do
    it 'should not accept mandate_date_of_signature in future' do
      subject = WireClient::DirectDebitTransaction.new(
        name: 'Some Merchant',
        wire_routing_number: '111900659',
        agent_name: 'BANK OF AMERICA',
        account_number: '3019586020',
        amount: 102.50,
        reference: 'XYZ-1234/123',
        remittance_information: 'Any information given',
        mandate_id: 'K-02-2011-12345',
        mandate_date_of_signature: Date.new(2018,9,10)
      )
      refute subject.valid?
      assert_equal subject.errors[:mandate_date_of_signature].size, 1
    end

    it 'should only accept mandate_date_of_signature as a Date' do
      subject = WireClient::DirectDebitTransaction.new(
        name: 'Some Merchant',
        wire_routing_number: '111900659',
        agent_name: 'BANK OF AMERICA',
        account_number: '3019586020',
        amount: 102.50,
        reference: 'XYZ-1234/123',
        remittance_information: 'Any information given',
        mandate_id: 'K-02-2011-12345',
        mandate_date_of_signature: '2018-09-10'
      )
      refute subject.valid?
      assert_equal subject.errors[:mandate_date_of_signature].size, 1
    end

    it 'should also validate the creditor_account' do
      subject = WireClient::DirectDebitTransaction.new(
        name: 'Some Merchant',
        wire_routing_number: '111900659',
        agent_name: 'BANK OF AMERICA',
        account_number: '3019586020',
        amount: 102.50,
        reference: 'XYZ-1234/123',
        remittance_information: 'Any information given',
        mandate_id: 'K-02-2011-12345',
        mandate_date_of_signature: '2018-09-10'
      )
      subject.creditor_account = WireClient::CreditorAccount.new
      refute subject.valid?
      assert_equal subject.errors[:creditor_account].size, 1
    end
  end
end
